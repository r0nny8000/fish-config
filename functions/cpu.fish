function cpu
    argparse --ignore-unknown 'h/help' 'temp' -- $argv
    or return

    # mactop only exists on Apple Silicon; btop is the closest equivalent
    # elsewhere, with htop as a last resort.
    set -l tool
    for candidate in mactop btop htop
        if command -q $candidate
            set tool $candidate
            break
        end
    end

    if set -q _flag_h
        set -l shown $tool
        test -n "$shown"; or set shown "<none installed>"

        echo "Usage: cpu [ARGS]..."
        echo "       cpu [--temp]"
        echo "       cpu [-h | --help]"
        echo ""
        echo "Monitor CPU, memory and processes with $shown."
        echo "Runs: $shown"
        echo ""
        echo "No sudo needed. Any extra ARGS are passed through, e.g.:"
        if test "$tool" = mactop
            echo "  cpu -i 500        Update every 500 ms"
            echo "  cpu --pid 1234    Monitor a specific process"
        else
            echo "  cpu -u 500        Update every 500 ms"
            echo "  cpu -p 1          Start with preset 1"
        end
        echo ""
        echo "Options:"
        echo "      --temp  Print temperature, frequency and throttling state"
        echo "  -h, --help  Show this help message and exit"
        return 0
    end

    if set -q _flag_temp
        __cpu_temp
        return
    end

    if test -z "$tool"
        echo "cpu: no system monitor found. Install one:" >&2
        echo "  Debian/Ubuntu: sudo apt install btop" >&2
        echo "  macOS:         brew install mactop" >&2
        return 1
    end

    command $tool $argv
end

function __cpu_temp --description 'CPU temperature, frequency and throttling state'
    set -l zone /sys/class/thermal/thermal_zone0/temp
    set -l freq /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq

    if not test -r $zone
        echo "cpu: no thermal sensor at $zone" >&2
        echo "     On macOS run plain 'cpu' — mactop shows temperature and power." >&2
        return 1
    end

    printf "Temperature  %.1f °C\n" (math (cat $zone) / 1000)

    if test -r $freq
        printf "Frequency    %.0f MHz\n" (math (cat $freq) / 1000)
    end

    # Throttling and under-voltage are only exposed by the VideoCore firmware.
    command -q vcgencmd; or return 0

    set -l raw (vcgencmd get_throttled 2>&1)
    if not string match -q 'throttled=0x*' -- $raw
        echo "Throttling   unavailable ($raw)"
        echo "             fix: sudo usermod -aG video $USER, then log out and back in"
        return 0
    end

    set -l bits (math (string replace 'throttled=' '' -- $raw))
    set -l flags "under-voltage" "frequency capped" "throttled" "soft temp limit"

    set -l now
    set -l past
    for i in (seq 4)
        if test (math "floor($bits / 2^"(math $i - 1)") % 2") -eq 1
            set -a now $flags[$i]
        end
        if test (math "floor($bits / 2^"(math $i + 15)") % 2") -eq 1
            set -a past $flags[$i]
        end
    end

    test (count $now) -gt 0
    and echo "Throttling   "(string join ', ' $now)
    or echo "Throttling   none"

    test (count $past) -gt 0
    and echo "Since boot   "(string join ', ' $past)
end
