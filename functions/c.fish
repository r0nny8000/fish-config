function c --description 'Show files in the terminal: markdown through glow, everything else through bat'
    # Probe for the tool rather than testing the platform. bat is packaged for
    # macOS and Debian alike, where it is named batcat to avoid a clash with
    # bacula. cat is always present as a last resort.
    set -l pager
    for candidate in bat batcat cat
        if command -q $candidate
            set pager $candidate
            break
        end
    end

    echo ""
    for file in $argv
        if not test -e $file
            echo "c: $file: No such file or directory" >&2
        else if string match -qri '\.(md|markdown)$' -- $file; and command -q glow
            glow $file
        else
            command $pager $file
        end
    end
end
