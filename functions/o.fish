function o --description 'Open files: text and markdown in the terminal, everything else in the desktop default app'
    # Prefer xdg-open explicitly on Linux: /usr/bin/open there is an
    # alternatives link that may point at run-mailcap rather than xdg-open,
    # and on some systems it is openvt from util-linux.
    set -l opener
    if command -q xdg-open
        set opener xdg-open
    else if command -q open
        set opener open
    end

    # ccat has no Debian package; bat is the usual replacement and ships as
    # batcat there to avoid a name clash. cat is the last resort.
    set -l pager
    for candidate in ccat batcat bat cat
        if command -q $candidate
            set pager $candidate
            break
        end
    end

    if test -z "$opener"
        echo "o: no file opener found (expected xdg-open or open)" >&2
        return 1
    end

    if test (count $argv) -eq 0
        command $opener
        return
    end

    if string match -q -- '-*' $argv
        command $opener $argv
        return
    end

    echo ""
    for file in $argv
        if not test -e $file
            echo "o: $file: No such file or directory" >&2
            continue
        end

        switch (string lower -- $file)
            case '*.md' '*.markdown'
                if command -q glow
                    glow $file
                else
                    command $pager $file
                end
                continue
        end

        if test (file --brief --mime-encoding -- $file) = binary
            command $opener $file
        else
            command $pager $file
        end
    end
end
