# my fish-config

Personal fish shell configuration. Its goal is to turn a new Linux machine — or
a Mac — into a working fish environment with all the tools needed for work, by
cloning this repo and running one script. New tools, functions and per-tool
configuration are added here, so every machine gets them.

`install.sh` installs fish and the tools, and symlinks this repo to
`~/.config/fish`. The config sets a TokyoNight colour theme and the default key
bindings, and adds a set of short alias functions.

## Installation

On a new machine, get git and clone the repo where it will stay — the symlink
points at the clone:

```sh
sudo apt install git        # macOS: install Homebrew first, https://brew.sh
git clone https://github.com/r0nny8000/fish-config.git ~/code/fish-config
cd ~/code/fish-config
./install.sh --yes
```

Options:

```sh
./install.sh                # prompts before installing missing tools
./install.sh --yes          # install and set the login shell without prompting
./install.sh --skip-tools   # symlink only
```

`install.sh` is idempotent: re-running it completes whatever is missing rather
than redoing work. It backs up an existing `~/.config/fish` before symlinking,
respects `XDG_CONFIG_HOME`, installs fish and whichever dependencies are not
already present, and makes fish your login shell, adding it to `/etc/shells`
first. It asks before installing or changing anything unless `--yes` is given;
with `--skip-tools` it prints the login-shell commands instead of running them.

The dependency list lives in the `TOOLS` table inside `install.sh`, one row per
tool: the command to probe for (alternatives separated by `|`), the Homebrew
formula, the apt package, and for tools neither manager supplies either a Linux
release archive (a `.tar.gz` URL, `{arch}` standing for `uname -m`) that
`install.sh` downloads into `/usr/local/bin`, or a URL it reports for a manual
install.

## Testing

```sh
tests/install-test.sh                 # debian:13
tests/install-test.sh ubuntu:24.04    # any apt-based image
```

Runs `install.sh` for real inside a fresh container, as a normal user with
sudo, and checks the result: the symlink and the backup of an existing config,
`config.local.fish`, that every tool from the `TOOLS` table with an apt package
or a release download — fish included — is on `PATH` afterwards, that fish is
the login shell and starts cleanly, that each function runs with its real tool,
and that a second run changes nothing. Each
check prints `ok` or `FAIL`; on failure both install logs follow.

Needs podman or docker (`sudo apt install podman` runs rootless). It installs the
full dependency list, so a run takes several minutes and needs network access.
Homebrew, the macOS-only `fixql`, and `n` (its `nerdctl` is not in apt) are not
covered.

## Project Structure

```
config.fish          # Main config: TokyoNight colour theme, default key bindings
config.local.fish    # Secrets and machine-specific values (gitignored, created by install.sh)
conf.d/              # Per-tool configuration, one file per tool (auto-loaded)
functions/           # One fish function per file (auto-loaded)
install.sh           # Installs fish and the tools, symlinks this repo to ~/.config/fish
tests/               # install-test.sh: runs install.sh for real in a container
fish_variables       # Fish universal variables (gitignored)
```

## Conventions

- **Tool configuration lives in `conf.d/<tool>.fish`**: PATH entries,
  environment variables and init lines, one file per tool and tracked in git,
  so a new machine gets them. fish loads these before `config.fish`. There are
  no snippets yet; the directory appears with the first one.
- **Secrets live in `config.local.fish`**, which is gitignored. No tokens or
  credentials are committed.
- **Short alias functions** in `functions/`: most are single-letter wrappers
  that print a blank line before their output for readability.
- **Cross-platform**: the repo is symlinked on both macOS and Linux, so
  functions detect the tool or interface they need at runtime instead of
  hardcoding a platform-specific name, and print a useful message when nothing
  suitable is installed.

## Local Environment (config.local.fish)

Not tracked in git; `config.fish` sources it and `install.sh` creates it empty.
Keep it to what must not or cannot be shared: tokens, credentials, and values
that really differ between machines. Anything a new machine should also get
belongs in `conf.d/` instead.

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
steps. Apart from fish itself, nothing breaks if a tool is missing — only the
function that uses it stops working.

| Tool | Used by | macOS | Linux (Debian / Raspberry Pi OS) |
|------|---------|-------|----------------------------------|
| `fish` | the shell itself | `brew install fish` | `sudo apt install fish` |
| `curl` | `install.sh`, for release downloads | built in | `sudo apt install curl` |
| `git` | `g`, `gl`, `gr` | preinstalled | `sudo apt install git` |
| `python` | `json` | preinstalled | `sudo apt install python-is-python3` |
| `nvim` | `v` | `brew install neovim` | `sudo apt install neovim` |
| `tree` | `t` | `brew install tree` | `sudo apt install tree` |
| `lsd` | `l`, `ll` | `brew install lsd` | `sudo apt install lsd` |
| `glow` | `c` | `brew install glow` | `sudo apt install glow` |
| `bat` | `c` | `brew install bat` | `sudo apt install bat` — installed as `batcat` |
| `nerdctl` | `n` | — (Homebrew's formula is Linux only) | see below |
| coreutils | `sha256sum` | `brew install coreutils` | built in |
| `btop` | `cpu` | — (uses `mactop`) | `sudo apt install btop` |
| `mactop` | `cpu` | `brew install mactop` | — (Apple Silicon only) |
| `vcgencmd` | `cpu --temp` | — | `sudo apt install raspi-utils-core` |
| `bandwhich` | `wifi` | `brew install bandwhich` | release download, see below |
| `claude` | `cc` | https://claude.com/claude-code | https://claude.com/claude-code |
| `caffeinate` | `cc` | built in | `systemd-inhibit`, part of systemd |
| `hostname` | `fish_prompt` | built in | `sudo apt install hostname` |

`tests/install-test.sh` also needs podman or docker. It is not in the `TOOLS`
table, so `install.sh` does not install it.

### Tools not in the Debian repositories

`bandwhich` publishes prebuilt Linux binaries, so `install.sh` downloads the
release for the machine's architecture into `/usr/local/bin`. Bump the version
in its `TOOLS` row as new releases appear.

`nerdctl` is reported rather than installed: on its own the binary does
nothing, it needs containerd running and a rootless setup. Releases are at
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
