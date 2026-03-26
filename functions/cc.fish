function cc
    argparse 'a/auto' 'C/no-caffeinate' 'h/help' -- $argv
    or return

    if set -q _flag_h
        echo "Usage: cc [-a | --auto] [-C | --no-caffeinate] [ARGS]..."
        echo "       cc [-h | --help]"
        echo ""
        echo "Short alias for the claude CLI."
        echo "Wraps claude with caffeinate to prevent sleep during sessions."
        echo ""
        echo "Options:"
        echo "  -a, --auto            Enable auto mode (passes --enable-auto-mode to claude)"
        echo "  -C, --no-caffeinate   Don't prevent system sleep (skips caffeinate wrapper)"
        echo "  -h, --help            Show this help message and exit"
        return 0
    end

    set -l claude_args $argv
    if set -q _flag_a
        set -p claude_args --enable-auto-mode
    end

    if set -q _flag_C
        claude $claude_args
    else
        command caffeinate -di claude $claude_args
    end
end
