function o --description 'Open files: text/markdown in terminal, everything else via macOS open'
    if test (count $argv) -eq 0
        command open
        return
    end

    if string match -q -- '-*' $argv
        command open $argv
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
                glow $file
                continue
        end

        if test (file --brief --mime-encoding -- $file) = binary
            command open $file
        else
            ccat $file
        end
    end
end
