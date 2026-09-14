# zoxide's own fish setup, as its README recommends: defines z to jump to a
# directory by keyword or path, and zi to pick one with fzf.
if command -q zoxide
    zoxide init fish | source
end
