# Fish Shell Configuration

Personal fish shell configuration, deployed via symlink to `~/.config/fish`.

## Project Structure

```
config.fish          # Main config: Dracula color theme, default key bindings, EDITOR=vim
config.local.fish    # Machine-local config (gitignored) - secrets, PATH, toolchain setup
install.sh           # Symlinks this repo to ~/.config/fish, prints post-install steps
functions/           # Fish function files (auto-loaded by fish)
completions/         # Fish completions (currently empty)
conf.d/              # Auto-loaded conf snippets (currently empty)
fish_variables       # Fish universal variables (gitignored)
```

## Key Conventions

- **Secrets live in `config.local.fish`** (gitignored). Never commit tokens or credentials.
- **Short alias functions** in `functions/`: most are single-letter wrappers that print a blank line before output for readability.
- **Color theme**: Dracula-based (defined in `config.fish`).

## Local Environment (config.local.fish)

Managed per-machine, sets up: locale, Homebrew, pyenv, Java/Maven/Groovy, compiler flags (LDFLAGS/CFLAGS/CPPFLAGS), and tokens for GitHub/JFrog/Jira. Not tracked in git.

## Installation

```sh
./install.sh
```

`install.sh` is idempotent: it backs up an existing `~/.config/fish` before
symlinking, respects `XDG_CONFIG_HOME`, and prints the remaining manual steps
(adding fish to `/etc/shells` and `chsh`) with the fish path detected on that
machine, skipping whichever step is already done.

## Dependencies

See the Dependencies table in `README.md` for the full list of external tools
the functions call, with the install command for macOS and for Debian /
Raspberry Pi OS. Keep that table in sync when a function gains or drops a tool.

Functions are expected to work on both macOS and Linux, since this repo is
symlinked on both. Detect the tool or interface at runtime rather than
hardcoding a platform-specific name, and degrade with a useful message when
nothing suitable is installed.
