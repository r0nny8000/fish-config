function wifi
    argparse --ignore-unknown 'h/help' -- $argv
    or return

    if set -q _flag_h
        echo "Usage: wifi [ARGS]..."
        echo "       wifi [-h | --help]"
        echo ""
        echo "Monitor Wi-Fi bandwidth with bandwhich (processes only)."
        echo "Runs: sudo bandwhich -p -i en0 -u si-bits"
        echo ""
        echo "  -p         Processes table only"
        echo "  -i en0     Wi-Fi interface only"
        echo "  -u si-bits Units in Mbit (decimal) — matches ISP line speed"
        echo ""
        echo "Any extra ARGS are passed through to bandwhich."
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message and exit"
        return 0
    end

    command sudo bandwhich -p -i en0 -u si-bits $argv
end
