# Instructions for Claude

`README.md` is the project documentation: goal, layout, installation,
conventions, the function list and the dependency table. Read it for context
before working here, and keep it current — this file holds only working
instructions, no project description.

## Where things go

- New tool: a row in the `TOOLS` table in `install.sh` and in the Dependencies
  table in `README.md`. If neither apt nor Homebrew has it but it publishes a
  Linux release archive, put the `.tar.gz` URL in the last column, with
  `{arch}` for `uname -m`.
- New function: `functions/<name>.fish` and a row in the Function Aliases table
  in `README.md`.
- Tool configuration (PATH, environment variables, init lines):
  `conf.d/<tool>.fish`, tracked in git so every machine gets it.
- Secrets and machine-specific values: `config.local.fish` only, which is
  gitignored. Never commit tokens or credentials.

## Writing functions

- Functions must work on both macOS and Linux, since this repo is symlinked on
  both. Detect the tool or interface at runtime rather than hardcoding a
  platform-specific name, and degrade with a useful message when nothing
  suitable is installed.
- 4-space indentation (`fish_indent -w`) and a `--description` on the
  function. Short wrappers print a blank line before their output.

## Changing install.sh

- Keep it idempotent: re-running it must complete what is missing without
  redoing work that is already done.

## Done means

- `shellcheck install.sh tests/install-test.sh` and `fish_indent --check` on
  the changed fish files are clean.
- `tests/install-test.sh` passes. A new function gets a check there that runs
  it with its real tool.
- The `TOOLS` table and the README tables match the change.

## Git

- Work on a branch. When `tests/install-test.sh` passes, fast-forward `master`
  to it and push; if it fails, do not merge.

## Stop and ask when

- A tool is not available from apt, Homebrew or a Linux release archive.
- A change would remove existing behaviour.
- Anything needs a secret.
