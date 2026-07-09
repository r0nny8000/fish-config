function fixql --description 'Clear quarantine flag on QLMarkdown.app and reload Quick Look'
    set -l app /Applications/QLMarkdown.app

    if not test -d $app
        echo "fixql: $app not found" >&2
        return 1
    end

    if not xattr $app | grep -q com.apple.quarantine
        echo "fixql: no quarantine flag set — nothing to do"
        return 0
    end

    xattr -r -d com.apple.quarantine $app
    and qlmanage -r >/dev/null 2>&1
    and echo "fixql: quarantine cleared and Quick Look reloaded"
end
