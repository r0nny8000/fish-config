function cpu
    argparse --ignore-unknown 'h/help' -- $argv
    or return

    if set -q _flag_h
        echo "Usage: cpu [ARGS]..."
        echo "       cpu [-h | --help]"
        echo ""
        echo "Monitor CPU, GPU, ANE, memory and power with mactop."
        echo "Runs: mactop"
        echo ""
        echo "No sudo needed for core metrics (uses native Apple APIs)."
        echo "Any extra ARGS are passed through to mactop, e.g.:"
        echo "  cpu -i 500        Update every 500 ms"
        echo "  cpu --pid 1234    Monitor a specific process"
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message and exit"
        return 0
    end

    command mactop $argv
end
