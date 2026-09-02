function wifi
    argparse --ignore-unknown 'h/help' -- $argv
    or return

    # Wi-Fi interface name differs per OS: wlan0-style on Linux, en0 on macOS.
    set -l iface
    if test -d /sys/class/net
        for dev in (command ls /sys/class/net)
            if test -d /sys/class/net/$dev/wireless
                set iface $dev
                break
            end
        end
    else
        set iface (networksetup -listallhardwareports 2>/dev/null \
            | awk '/Wi-Fi|AirPort/{getline; print $2; exit}')
    end

    if set -q _flag_h
        set -l shown $iface
        test -n "$shown"; or set shown "<none>"

        echo "Usage: wifi [ARGS]..."
        echo "       wifi [-h | --help]"
        echo ""
        echo "Monitor Wi-Fi bandwidth with bandwhich (processes only)."
        echo "Runs: sudo bandwhich -p -i $shown -u si-bits"
        echo ""
        printf "  %-11s%s\n" "-p" "Processes table only"
        printf "  %-11s%s\n" "-i $shown" "Wi-Fi interface only (detected automatically)"
        printf "  %-11s%s\n" "-u si-bits" "Units in Mbit (decimal) — matches ISP line speed"
        echo ""
        echo "Any extra ARGS are passed through to bandwhich."
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message and exit"
        return 0
    end

    if test -z "$iface"
        echo "wifi: no Wi-Fi interface found." >&2
        return 1
    end

    command sudo bandwhich -p -i $iface -u si-bits $argv
end
