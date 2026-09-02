# my fish-config

## Function Aliases

| Function | Command | Description |
|----------|---------|-------------|
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
| `o`      | `ccat` / `bat` / `glow` / `open` / `xdg-open` | Smart file opener: text and markdown in the terminal, everything else in the desktop default app |
| `sha256sum` | `gsha256sum` / `sha256sum` / `shasum` | SHA-256, whichever implementation is present |
| `t`      | `tree` | Tree shortcut |
| `v`      | `nvim` | Neovim shortcut |
| `wifi`   | `bandwhich` | Per-process Wi-Fi bandwidth |

## Dependencies

The functions call external tools. Nothing breaks if a tool is missing — only
the function that uses it stops working. Install what you actually use.

| Tool | Used by | macOS | Linux (Debian / Raspberry Pi OS) |
|------|---------|-------|----------------------------------|
| `git` | `g`, `gl`, `gr` | preinstalled | `sudo apt install git` |
| `python` | `json` | preinstalled | `sudo apt install python-is-python3` |
| `nvim` | `v` | `brew install neovim` | `sudo apt install neovim` |
| `tree` | `t` | `brew install tree` | `sudo apt install tree` |
| `lsd` | `l`, `ll` | `brew install lsd` | `sudo apt install lsd` |
| `glow` | `o` | `brew install glow` | `sudo apt install glow` |
| `ccat` | `o` | `brew install ccat` | `sudo apt install bat` — used automatically |
| `nerdctl` | `n` | `brew install nerdctl` | see below |
| coreutils | `sha256sum` | `brew install coreutils` | built in |
| `btop` | `cpu` | — (uses `mactop`) | `sudo apt install btop` |
| `mactop` | `cpu` | `brew install mactop` | — (Apple Silicon only) |
| `vcgencmd` | `cpu --temp` | — | `sudo apt install raspi-utils-core` |
| `bandwhich` | `wifi` | `brew install bandwhich` | see below |
| `claude` | `cc` | https://claude.com/claude-code | https://claude.com/claude-code |
| `caffeinate` | `cc` | built in | `systemd-inhibit`, part of systemd |
| `open` | `o` | built in | `xdg-open`, preinstalled |
| `file` | `o` | built in | preinstalled |

### Tools not in the Debian repositories

`bandwhich` publishes prebuilt Linux binaries:

```sh
curl -sL https://github.com/imsnif/bandwhich/releases/download/v0.23.1/bandwhich-v0.23.1-aarch64-unknown-linux-gnu.tar.gz \
  | sudo tar -xz -C /usr/local/bin bandwhich
```

Swap `aarch64` for `x86_64` on Intel/AMD machines, and bump the version as new
releases appear. `nerdctl` is distributed the same way, from
https://github.com/containerd/nerdctl/releases.

`ccat` has no Debian package. `o` falls back to `bat` (`sudo apt install bat`,
installed as `batcat` on Debian to avoid a name clash) and then to plain `cat`,
so it works either way.

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
