#!/bin/bash
#
# Symlinks this repo to the fish config directory (~/.config/fish by default),
# installs the tools the functions depend on, and prints the remaining manual
# steps. Safe to re-run: it completes whatever is missing and touches nothing
# that is already in place.

set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: ./install.sh [-y | --yes] [--skip-tools]
       ./install.sh [-h | --help]

  -y, --yes         Install missing tools without asking
      --skip-tools  Only set up the symlink, install nothing
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
    echo "# Machine-local config: secrets, PATH, toolchain setup." > "$repo_dir/config.local.fish"
    echo "Created empty config.local.fish"
fi

# --- tools -----------------------------------------------------------------
#
# One row per dependency:
#   <probe>  <homebrew formula>  <apt package>  <manual install URL>
#
# The probe is the command the functions actually call; several alternatives
# separated by "|" mean any one of them satisfies the dependency. A "-" means
# that package manager cannot supply the tool, in which case the manual URL is
# reported instead. Tools that are part of the base system on both platforms
# (awk, sed, grep, find, sort, cat, file utilities, caffeinate, systemd-inhibit,
# xdg-open, open, xattr, qlmanage) are deliberately absent.

TOOLS='
git                     git         git                 -
nvim                    neovim      neovim              -
tree                    tree        tree                -
lsd                     lsd         lsd                 -
glow                    glow        glow                -
file                    -           file                -
hostname                -           hostname            -
python                  -           python-is-python3   https://github.com/pyenv/pyenv
mactop|btop             mactop      btop                -
gsha256sum|sha256sum    coreutils   -                   -
ccat|batcat|bat         ccat        bat                 -
nerdctl                 nerdctl     -                   https://github.com/containerd/nerdctl/releases
bandwhich               bandwhich   -                   https://github.com/imsnif/bandwhich/releases
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
                unavailable="$unavailable $probe"
                pkg="-"
            fi

            if [ "$pkg" != "-" ]; then
                pkgs="$pkgs $pkg"
            elif [ "$note" != "-" ]; then
                manual="$manual
  $probe — $note"
            else
                unavailable="$unavailable $probe"
            fi
        done <<EOF
$TOOLS
EOF

        if [ -z "$pkgs" ]; then
            echo "All packaged tools are already installed."
        else
            echo "Missing tools:$pkgs"
            do_install=no
            if [ "$assume_yes" = yes ]; then
                do_install=yes
            elif [ -t 0 ]; then
                printf 'Install them with %s? [y/N] ' "$pm"
                read -r reply
                case $reply in
                    [yY]*) do_install=yes ;;
                esac
            else
                echo "Not running in a terminal — re-run with --yes to install."
            fi

            if [ "$do_install" = yes ]; then
                if [ "$pm" = brew ]; then
                    # shellcheck disable=SC2086
                    brew install $pkgs || echo "install.sh: some formulae failed, continuing."
                else
                    # shellcheck disable=SC2086
                    sudo apt-get update \
                        && sudo apt-get install -y $pkgs \
                        || echo "install.sh: some packages failed, continuing."
                fi
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

# Resolve through any symlinks so /etc/shells gets the real interpreter path.
fish_path=$(readlink -f "$fish_path" 2>/dev/null || echo "$fish_path")
echo "fish is installed here: $fish_path"

if [ -f /etc/shells ] && grep -qxF "$fish_path" /etc/shells; then
    echo "Already listed in /etc/shells."
else
    echo
    echo "Add it to /etc/shells:"
    echo "  echo $fish_path | sudo tee -a /etc/shells"
fi

user=${USER:-$(id -un)}
current_shell=$(getent passwd "$user" 2>/dev/null | cut -d: -f7 \
    || dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}' \
    || true)

if [ "$current_shell" = "$fish_path" ]; then
    echo "Already your login shell."
else
    echo
    echo "Then make it your login shell (no sudo needed for your own account):"
    echo "  chsh -s $fish_path"
fi
