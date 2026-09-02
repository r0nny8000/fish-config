#!/bin/bash
#
# Symlinks this repo to the fish config directory (~/.config/fish by default)
# and prints the remaining manual steps. Safe to re-run.

set -euo pipefail

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

echo
ls -la "$target"
echo

# --- login shell -----------------------------------------------------------

fish_path=$(command -v fish || true)

if [ -z "$fish_path" ]; then
    echo "fish is not installed or not on PATH. Install it first:"
    echo "  macOS:        brew install fish"
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
