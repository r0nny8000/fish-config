function cc
    argparse 'a/auto' 'h/help' -- $argv
    or return

    if set -q _flag_h
        echo "Usage: cc [-a | --auto] [ARGS]..."
        echo "       cc [-h | --help]"
        echo ""
        echo "Short alias for the claude CLI."
        echo ""
        echo "Options:"
        echo "  -a, --auto    Enable auto mode (passes --enable-auto-mode to claude)"
        echo "  -h, --help    Show this help message and exit"
        return 0
    end

    if set -q _flag_a
        claude --enable-auto-mode $argv
    else
        claude $argv
    end
end
