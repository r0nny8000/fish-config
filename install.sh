#!/bin/bash
#
# Symlinks this repo to the fish config directory (~/.config/fish by default),
# installs fish and the tools the functions depend on, makes fish the login
# shell, and prints whatever is left to do by hand. Safe to re-run: it completes
# whatever is missing and touches nothing that is already in place.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: ./install.sh [-y | --yes] [--skip-tools]
       ./install.sh [-h | --help]

  -y, --yes         Install missing tools and set the login shell without asking
      --skip-tools  Only set up the symlink: install nothing, keep the login shell
  -h, --help        Show this help and exit
USAGE
}

assume_yes=no
skip_tools=no

while [ $# -gt 0 ]; do
    case $1 in
        -y|--yes)     assume_yes=yes ;;
        --skip-tools) skip_tools=yes ;;
        -h|--help)    usage; exit 0 ;;
        *) echo "install.sh: unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
    shift
done

# Asks a yes/no question. --yes answers it; without a terminal the answer is no.
confirm() {
    if [ "$assume_yes" = yes ]; then
        return 0
    fi
    if [ ! -t 0 ]; then
        echo "Not running in a terminal — re-run with --yes to do this."
        return 1
    fi
    printf '%s [y/N] ' "$1"
    read -r reply
    case $reply in
        [yY]*) return 0 ;;
    esac
    return 1
}

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
config_home=${XDG_CONFIG_HOME:-$HOME/.config}
target=$config_home/fish

echo "origin: $repo_dir"
echo "target: $target"
echo

# --- symlink ---------------------------------------------------------------

mkdir -p "$config_home"

if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$repo_dir" ]; then
    echo "Symlink already points here, nothing to do."
elif [ -e "$target" ] || [ -L "$target" ]; then
    backup=$target.legacy
    if [ -e "$backup" ] || [ -L "$backup" ]; then
        backup=$target.legacy-$(date +%Y%m%d%H%M%S)
    fi
    echo "Moving existing config to $backup"
    mv "$target" "$backup"
    ln -s "$repo_dir" "$target"
    echo "Symlink created."
else
    ln -s "$repo_dir" "$target"
    echo "Symlink created."
fi

# config.fish sources this unconditionally; it is gitignored, so create an
# empty one rather than letting fish error on every startup.
if [ ! -e "$repo_dir/config.local.fish" ]; then
    echo "# Secrets and machine-specific values; tool configuration goes in conf.d/." > "$repo_dir/config.local.fish"
    echo "Created empty config.local.fish"
fi

# --- tools -----------------------------------------------------------------
#
# One row per dependency:
#   <probe>  <homebrew formula>  <apt package>  <release archive or manual URL>
#
# The probe is the command the functions actually call; several alternatives
# separated by "|" mean any one of them satisfies the dependency. A "-" means
# that package manager cannot supply the tool, and the last column is used
# instead: on apt systems a URL ending in .tar.gz is a Linux release archive,
# and the binary named like the probe is extracted from it into /usr/local/bin
# ({arch} stands for uname -m); any other URL is reported for a manual install.
# Tools that are part of the base system on both platforms
# (awk, sed, grep, find, sort, cat, caffeinate, systemd-inhibit, xattr,
# qlmanage) are deliberately absent.

TOOLS='
fish                    fish        fish                -
curl                    -           curl                -
git                     git         git                 -
nvim                    neovim      neovim              -
tree                    tree        tree                -
lsd                     lsd         lsd                 -
glow                    glow        glow                -
hostname                -           hostname            -
python                  -           python-is-python3   https://github.com/pyenv/pyenv
mactop|btop             mactop      btop                -
gsha256sum|sha256sum    coreutils   -                   -
bat|batcat              bat         bat                 -
nerdctl                 -           -                   https://github.com/containerd/nerdctl/releases
bandwhich               bandwhich   -                   https://github.com/imsnif/bandwhich/releases/download/v0.23.1/bandwhich-v0.23.1-{arch}-unknown-linux-gnu.tar.gz
vcgencmd                -           raspi-utils-core    -
claude                  -           -                   https://claude.com/claude-code
'

have() {
    local cmd
    local IFS='|'
    for cmd in $1; do
        if command -v "$cmd" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

if [ "$skip_tools" = yes ]; then
    echo
    echo "Skipping tool installation (--skip-tools)."
else
    if command -v brew >/dev/null 2>&1; then
        pm=brew
    elif command -v apt-get >/dev/null 2>&1; then
        pm=apt
    else
        pm=none
    fi

    echo
    if [ "$pm" = none ]; then
        echo "No supported package manager found (expected brew or apt-get)."
        echo "On macOS install Homebrew first: https://brew.sh"
    else
        pkgs=""
        downloads=""
        missing=""
        manual=""
        unavailable=""

        while read -r probe brew_pkg apt_pkg note; do
            if [ -z "${probe:-}" ]; then
                continue
            fi
            if have "$probe"; then
                continue
            fi

            if [ "$pm" = brew ]; then
                pkg=$brew_pkg
            else
                pkg=$apt_pkg
            fi

            # raspi-utils-core and friends do not exist outside Raspberry Pi OS.
            if [ "$pkg" != "-" ] && [ "$pm" = apt ] && ! apt-cache show "$pkg" >/dev/null 2>&1; then
                pkg="-"
            fi

            if [ "$pkg" != "-" ]; then
                pkgs="$pkgs $pkg"
                missing="$missing $pkg"
            elif [ "$pm" = apt ] && [ "${note%.tar.gz}" != "$note" ]; then
                downloads="$downloads
$probe $note"
                missing="$missing $probe"
            elif [ "$note" != "-" ]; then
                manual="$manual
  $probe — $note"
            else
                unavailable="$unavailable $probe"
            fi
        done <<EOF
$TOOLS
EOF

        if [ -z "$missing" ]; then
            echo "All packaged tools are already installed."
        else
            echo "Missing tools:$missing"
            if confirm "Install them?"; then
                if [ -n "$pkgs" ] && [ "$pm" = brew ]; then
                    # shellcheck disable=SC2086
                    brew install $pkgs || echo "install.sh: some formulae failed, continuing."
                elif [ -n "$pkgs" ]; then
                    # shellcheck disable=SC2086
                    sudo apt-get update \
                        && sudo apt-get install -y $pkgs \
                        || echo "install.sh: some packages failed, continuing."
                fi

                # After apt, so a fresh system already has curl.
                arch=$(uname -m)
                while read -r name url; do
                    if [ -z "$name" ]; then
                        continue
                    fi
                    echo "Downloading $name"
                    curl -fsSL "${url//\{arch\}/$arch}" \
                        | sudo tar -xz --no-same-owner -C /usr/local/bin "$name" \
                        || echo "install.sh: downloading $name failed, continuing."
                done <<EOF
$downloads
EOF
            fi
        fi

        if [ -n "$manual" ]; then
            echo
            echo "Not available from $pm, install manually:$manual"
        fi
        if [ -n "$unavailable" ]; then
            echo
            echo "Not applicable on this system, skipped:$unavailable"
        fi
    fi
fi

echo
ls -la "$target"
echo

# --- login shell -----------------------------------------------------------

fish_path=$(command -v fish || true)

if [ -z "$fish_path" ]; then
    echo "fish is not installed or not on PATH. Install it first:"
    echo "  macOS:         brew install fish"
    echo "  Debian/Ubuntu: sudo apt install fish"
    exit 0
fi

# Keep the PATH entry rather than resolving it: Homebrew's bin/fish points into
# a versioned Cellar directory that changes with every fish upgrade.
echo "fish is installed here: $fish_path"

# getent is Linux-only, and a missing one still leaves the pipeline exiting 0,
# so pick the tool up front instead of chaining fallbacks.
user=${USER:-$(id -un)}
if command -v getent >/dev/null 2>&1; then
    current_shell=$(getent passwd "$user" | cut -d: -f7 || true)
else
    current_shell=$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}' || true)
fi

if [ "$current_shell" = "$fish_path" ]; then
    echo "Already your login shell."
elif [ "$skip_tools" = no ] && confirm "Make fish your login shell?"; then
    # chsh only accepts shells listed in /etc/shells.
    if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
        echo "$fish_path" | sudo tee -a /etc/shells >/dev/null
    fi
    if sudo chsh -s "$fish_path" "$user"; then
        echo "Login shell set to fish; it applies from your next login."
    else
        echo "install.sh: chsh failed, run: chsh -s $fish_path"
    fi
else
    echo
    echo "To make fish your login shell:"
    if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
        echo "  echo $fish_path | sudo tee -a /etc/shells"
    fi
    echo "  chsh -s $fish_path"
fi
