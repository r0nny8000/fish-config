# my fish-config

Personal fish shell configuration, deployed by symlinking this repo to
`~/.config/fish`. It sets a Dracula colour theme, the default key bindings and
`EDITOR=vim`, and adds a set of short alias functions.

## Installation

```sh
./install.sh                # prompts before installing missing tools
./install.sh --yes          # install without prompting
./install.sh --skip-tools   # symlink only
```

`install.sh` is idempotent: re-running it completes whatever is missing rather
than redoing work. It backs up an existing `~/.config/fish` before symlinking,
respects `XDG_CONFIG_HOME`, installs only the dependencies that are not already
present, and prints the remaining manual steps — adding fish to `/etc/shells`
and `chsh` — with the fish path detected on that machine, skipping whichever
step is already done.

The dependency list lives in the `TOOLS` table inside `install.sh`, one row per
tool: the command to probe for (alternatives separated by `|`), the Homebrew
formula, the apt package, and a URL for tools neither manager supplies.

## Testing

```sh
tests/install-test.sh                 # debian:13
tests/install-test.sh ubuntu:24.04    # any apt-based image
```

Runs `install.sh` for real inside a fresh container, as a normal user with
sudo, and checks the result: the symlink and the backup of an existing config,
`config.local.fish`, that every tool from the `TOOLS` table with an apt package
is on `PATH` afterwards, that fish starts cleanly, and that a second run changes
nothing. Each check prints `ok` or `FAIL`; on failure both install logs follow.

Needs podman or docker (`sudo apt install podman` runs rootless). It installs the
full dependency list, so a run takes several minutes and needs network access.
Homebrew and the macOS-only tools are not covered.

## Project Structure

```
config.fish          # Main config: Dracula color theme, default key bindings, EDITOR=vim
config.local.fish    # Machine-local config (gitignored) - secrets, PATH, toolchain setup
install.sh           # Symlinks this repo to ~/.config/fish, prints post-install steps
tests/               # install-test.sh: runs install.sh for real in a container
functions/           # Fish function files (auto-loaded by fish)
completions/         # Fish completions (currently empty)
conf.d/              # Auto-loaded conf snippets (currently empty)
fish_variables       # Fish universal variables (gitignored)
```

## Conventions

- **Secrets live in `config.local.fish`**, which is gitignored. No tokens or
  credentials are committed.
- **Short alias functions** in `functions/`: most are single-letter wrappers
  that print a blank line before their output for readability.
- **Cross-platform**: the repo is symlinked on both macOS and Linux, so
  functions detect the tool or interface they need at runtime instead of
  hardcoding a platform-specific name, and print a useful message when nothing
  suitable is installed.

## Local Environment (config.local.fish)

Machine-local and not tracked in git. It sets up locale, Homebrew, pyenv,
Java/Maven/Groovy, compiler flags (`LDFLAGS`/`CFLAGS`/`CPPFLAGS`), and tokens
for GitHub/JFrog/Jira.

## Function Aliases

| Function | Command | Description |
|----------|---------|-------------|
| `c`      | `bat` / `batcat` / `glow` | Show files in the terminal: markdown through `glow`, everything else through `bat` |
| `cc`     | `claude` (wrapped in `caffeinate` / `systemd-inhibit`) | Claude CLI, keeps the machine awake during sessions |
| `cpu`    | `mactop` / `btop` / `htop` | System monitor; `--temp` prints temperature, frequency and throttling |
| `fixql`  | `xattr`, `qlmanage` | Clear the quarantine flag on QLMarkdown.app (macOS only) |
| `g`      | `git status` | Git status shortcut |
| `gl`     | `git log --graph ...` | Pretty git log with graph |
| `gr`     | recursive git | Run a git command across all repos in subdirectories |
| `json`   | `python -m json.tool` | Format JSON |
| `l`      | `lsd` | List files with lsd |
| `ll`     | `lsd -la` | Long listing with lsd |
| `n`      | `nerdctl` | Container runtime shortcut |
| `sha256sum` | `gsha256sum` / `sha256sum` / `shasum` | SHA-256, whichever implementation is present |
| `t`      | `tree` | Tree shortcut |
| `v`      | `nvim` | Neovim shortcut |
| `wifi`   | `bandwhich` | Per-process Wi-Fi bandwidth |

## Dependencies

`./install.sh` installs everything in this table that Homebrew or apt can
supply, skipping whatever is already present, and reports the rest as manual
steps. Nothing breaks if a tool is missing — only the function that uses it
stops working.

| Tool | Used by | macOS | Linux (Debian / Raspberry Pi OS) |
|------|---------|-------|----------------------------------|
| `git` | `g`, `gl`, `gr` | preinstalled | `sudo apt install git` |
| `python` | `json` | preinstalled | `sudo apt install python-is-python3` |
| `nvim` | `v` | `brew install neovim` | `sudo apt install neovim` |
| `tree` | `t` | `brew install tree` | `sudo apt install tree` |
| `lsd` | `l`, `ll` | `brew install lsd` | `sudo apt install lsd` |
| `glow` | `c` | `brew install glow` | `sudo apt install glow` |
| `bat` | `c` | `brew install bat` | `sudo apt install bat` — installed as `batcat` |
| `nerdctl` | `n` | `brew install nerdctl` | see below |
| coreutils | `sha256sum` | `brew install coreutils` | built in |
| `btop` | `cpu` | — (uses `mactop`) | `sudo apt install btop` |
| `mactop` | `cpu` | `brew install mactop` | — (Apple Silicon only) |
| `vcgencmd` | `cpu --temp` | — | `sudo apt install raspi-utils-core` |
| `bandwhich` | `wifi` | `brew install bandwhich` | see below |
| `claude` | `cc` | https://claude.com/claude-code | https://claude.com/claude-code |
| `caffeinate` | `cc` | built in | `systemd-inhibit`, part of systemd |
| `hostname` | `fish_prompt` | built in | `sudo apt install hostname` |

`tests/install-test.sh` also needs podman or docker. It is not in the `TOOLS`
table, so `install.sh` does not install it.

### Tools not in the Debian repositories

`install.sh` reports these rather than installing them. `bandwhich` publishes
prebuilt Linux binaries:

```sh
curl -sL https://github.com/imsnif/bandwhich/releases/download/v0.23.1/bandwhich-v0.23.1-aarch64-unknown-linux-gnu.tar.gz \
  | sudo tar -xz -C /usr/local/bin bandwhich
```

Swap `aarch64` for `x86_64` on Intel/AMD machines, and bump the version as new
releases appear. `nerdctl` is distributed the same way, from
https://github.com/containerd/nerdctl/releases.

Debian installs `bat` as `batcat` to avoid a name clash with another package,
so `c` looks for `bat` and then `batcat`, and falls back to plain `cat` when
neither is present.

### Raspberry Pi: throttling in `cpu --temp`

Temperature and frequency are read from sysfs and need no privileges.
Throttling and under-voltage state come from the VideoCore firmware via
`vcgencmd`, which requires membership in the `video` group:

```sh
sudo usermod -aG video $USER   # then log out and back in
```

Without it, `cpu --temp` still prints temperature and frequency and tells you
about this step.

### macOS-only functions

`fixql` targets `/Applications/QLMarkdown.app` and uses `xattr` and `qlmanage`.
It is the only function with no Linux equivalent.
