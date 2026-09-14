#!/bin/bash
#
# Runs install.sh for real inside a fresh container and checks the result:
# symlink and backup, config.local.fish, every tool from the TOOLS table that
# apt or a release download provides (fish included), the login shell, each
# function run once with its real tool, and an idempotent second run.
#
#   tests/install-test.sh [image]    # default: debian:13
#
# Needs podman or docker on the host.
#
# The same file runs in three stages: on the host it starts the container,
# as root in the container it prepares a user with sudo, and as that user it
# runs the checks.

set -uo pipefail

# --- host: start the container ----------------------------------------------

if [ -z "${STAGE:-}" ]; then
    repo=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
    runtime=$(command -v podman || command -v docker) || {
        echo "install-test: needs podman or docker" >&2
        exit 1
    }
    exec "$runtime" run --rm -e STAGE=root -v "$repo:/src:ro" "${1:-debian:13}" \
        bash /src/tests/install-test.sh
fi

# --- container, root: prepare a sudo user and a clean copy of the repo ------

if [ "$STAGE" = root ]; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq && apt-get install -y -qq sudo >/dev/null || exit 1
    useradd -m tester
    echo 'tester ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/tester
    cp -r /src /home/tester/fish-config
    rm -f /home/tester/fish-config/config.local.fish /home/tester/fish-config/fish_variables
    chown -R tester: /home/tester/fish-config
    exec runuser -u tester -- env STAGE=user HOME=/home/tester USER=tester \
        bash /home/tester/fish-config/tests/install-test.sh
fi

# --- container, user: the checks --------------------------------------------

repo=$HOME/fish-config
passed=0
failed=0

check() {
    local name=$1
    shift
    if "$@" >/dev/null 2>&1; then
        echo "ok   - $name"
        passed=$((passed + 1))
    else
        echo "FAIL - $name"
        failed=$((failed + 1))
    fi
}

have() {
    local cmd IFS='|'
    for cmd in $1; do
        command -v "$cmd" && return 0
    done
    return 1
}

outputs() {
    local pattern=$1 out
    shift
    out=$("$@" 2>&1) && [[ $out == *"$pattern"* ]]
}

exits_with() {
    local code=$1
    shift
    "$@"
    [ $? -eq "$code" ]
}

check "--help exits 0" exits_with 0 "$repo/install.sh" --help
check "unknown option exits 1" exits_with 1 "$repo/install.sh" --bogus

# An existing config must be moved aside, not overwritten.
mkdir -p "$HOME/.config/fish"
echo old > "$HOME/.config/fish/config.fish"

check "first run exits 0" exits_with 0 bash -c "'$repo/install.sh' --yes > /tmp/run1.log 2>&1"
check "symlink points at the repo" test "$(readlink "$HOME/.config/fish")" = "$repo"
check "existing config moved to fish.legacy" grep -qx old "$HOME/.config/fish.legacy/config.fish"
check "config.local.fish created" test -f "$repo/config.local.fish"

while read -r probe _ apt_pkg note; do
    if [ -z "$probe" ]; then
        continue
    fi
    if [ "$apt_pkg" = - ]; then
        if [ "${note%.tar.gz}" != "$note" ]; then
            check "$probe installed from its release download" have "$probe"
        fi
        continue
    fi
    if ! apt-cache show "$apt_pkg" >/dev/null 2>&1; then
        echo "skip - $probe: $apt_pkg is not in this distribution"
        continue
    fi
    check "$probe installed from apt package $apt_pkg" have "$probe"
done < <(sed -n "/^TOOLS='/,/^'/p" "$repo/install.sh" | sed '1d;$d')

check "no tool reported twice as skipped" \
    bash -c "grep '^Not applicable' /tmp/run1.log | cut -d: -f2 | tr ' ' '\n' | grep . | sort | uniq -d | grep -q . && exit 1 || exit 0"
check "fish starts without errors" test -z "$(fish -c true 2>&1)"
check "fish is the login shell" test "$(getent passwd "$USER" | cut -d: -f7)" = "$(command -v fish)"

# Each function once, with the tool install.sh put there. Left out: n, whose
# nerdctl is not installable from apt, and fixql, which is macOS only.
check "c shows a file" outputs TOOLS fish -c "c '$repo/install.sh'"
check "c renders markdown" outputs Installation fish -c "c '$repo/README.md'"
check "cc --help runs" outputs "Usage: cc" fish -c 'cc --help'
check "cpu picks btop" outputs "Runs: btop" fish -c 'cpu --help'
check "fish_prompt runs" outputs "$USER" fish -c fish_prompt
check "g runs git status" fish -c "cd '$repo'; g"
check "gl runs git log" fish -c "cd '$repo'; gl -1"
check "gr runs git in each repo" outputs fish-config fish -c "cd; gr status"
check "json formats JSON" outputs '"a": 1' fish -c "echo '{\"a\":1}' | json"
check "l runs" fish -c 'l /'
check "ll runs" fish -c 'll /'
check "sha256sum hashes a file" outputs install.sh fish -c "sha256sum '$repo/install.sh'"
check "t runs" fish -c 't -L 1 /'
check "v starts neovim" outputs NVIM fish -c 'v --version'
check "wifi --help runs" outputs "Usage: wifi" fish -c 'wifi --help'
check "bandwhich runs" outputs bandwhich bandwhich --version

check "second run exits 0" exits_with 0 bash -c "'$repo/install.sh' --yes > /tmp/run2.log 2>&1"
check "second run keeps the symlink" grep -q "Symlink already points here" /tmp/run2.log
check "second run keeps the login shell" grep -q "Already your login shell" /tmp/run2.log
check "second run installs nothing" grep -q "All packaged tools are already installed" /tmp/run2.log
check "second run makes no new backup" bash -c "! ls -d '$HOME'/.config/fish.legacy-* 2>/dev/null"

echo
echo "$passed passed, $failed failed"

if [ "$failed" -gt 0 ]; then
    for log in /tmp/run1.log /tmp/run2.log; do
        echo
        echo "--- $log ---"
        cat "$log" 2>/dev/null
    done
    exit 1
fi
