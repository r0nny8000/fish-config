function sha256sum
  echo ""

  # GNU coreutils is gsha256sum under Homebrew and sha256sum on Linux;
  # macOS without coreutils only has shasum. 'command' avoids recursing
  # back into this function.
  if command -q gsha256sum
    command gsha256sum $argv
  else if command -q sha256sum
    command sha256sum $argv
  else if command -q shasum
    command shasum -a 256 $argv
  else
    echo "sha256sum: no SHA-256 tool found (brew install coreutils)." >&2
    return 1
  end
end
