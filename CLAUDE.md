# Instructions for Claude

`README.md` is the project documentation: layout, installation, conventions,
the function list and the dependency table. Read it for context before working
here, and keep it current — this file holds only working instructions, no
project description.

## Writing functions

- Functions must work on both macOS and Linux, since this repo is symlinked on
  both. Detect the tool or interface at runtime rather than hardcoding a
  platform-specific name, and degrade with a useful message when nothing
  suitable is installed.
- Follow the style of the existing functions in `functions/`: short wrappers
  that print a blank line before their output.

## Keeping things in sync

- When a function gains or drops an external tool, update both the `TOOLS`
  table in `install.sh` and the Dependencies table in `README.md`.
- When a function is added, removed or renamed, update the Function Aliases
  table in `README.md`.
- Keep `install.sh` idempotent: re-running it must complete what is missing
  without redoing work that is already done.

## Secrets

Never commit tokens or credentials. Machine-local settings and secrets belong
in `config.local.fish`, which is gitignored.
