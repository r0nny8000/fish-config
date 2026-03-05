function cc
    argparse 'a/auto' -- $argv
    or return

    if set -q _flag_a
        claude --enable-auto-mode $argv
    else
        claude $argv
    end
end
