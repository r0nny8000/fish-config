# Fish Shell Configuration

Personal fish shell configuration, deployed via symlink to `~/.config/fish`.

## Project Structure

```
config.fish          # Main config: Dracula color theme, default key bindings, EDITOR=vim
config.local.fish    # Machine-local config (gitignored) - secrets, PATH, toolchain setup
install.sh           # Symlinks this repo to ~/.config/fish, prints post-install steps
functions/           # Fish function files (auto-loaded by fish)
completions/         # Fish completions (currently empty)
conf.d/              # Auto-loaded conf snippets (theme + key binding migration from fish 4.3)
fish_variables       # Fish universal variables (gitignored)
```

## Key Conventions

- **Secrets live in `config.local.fish`** (gitignored). Never commit tokens or credentials.
- **Short alias functions** in `functions/`: most are single-letter wrappers that print a blank line before output for readability.
- **Color theme**: Dracula-based (defined in both `config.fish` and `conf.d/fish_frozen_theme.fish`).

## Local Environment (config.local.fish)

Managed per-machine, sets up: locale, Homebrew, pyenv, Java/Maven/Groovy, compiler flags (LDFLAGS/CFLAGS/CPPFLAGS), and tokens for GitHub/JFrog/Jira. Not tracked in git.

## Installation

```sh
./install.sh
# Then manually:
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

## Dependencies

External tools used by functions: `ccat`, `lsd`, `tree`, `nerdctl`, `gsha256sum` (coreutils), `pyenv`, Homebrew.
