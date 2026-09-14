# fzf's own fish setup, as its README recommends: Ctrl-R searches history,
# Ctrl-T pastes files and directories, Alt-C changes into a directory.
if command -q fzf
    fzf --fish | source
end
