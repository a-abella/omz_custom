###
### portping - test ports in a loop
###

function portping () {

    usage () {
        echo "Usage: portping HOST PORT [INTERVAL] [TIMEOUT]"
        echo
        echo "A utility to test connectivity using TCP-SYN pings"
        echo
        echo "Required arguments:"
        echo "  HOST        The target hostname or IP address to test"
        echo "  PORT        The target TCP port to test"
        echo
        echo "Optional arguments:"
        echo "  INTERVAL    The number of seconds to wait between tests,"
        echo "                default 1"
        echo "  TIMEOUT     The number of seconds to wait for a response,"
        echo "                default 1"
        echo
        echo "Example resulting test command:"
        echo "  nc -zvw TIMEOUT HOST PORT ; sleep INTERVAL"
        echo
    }

    if [[ $# -lt 2 || $# -gt 4 ]]; then
       echo 'portping: error: incorrect number of arguments' >&2
       usage
       return 1
    fi

    local target_host="$1"
    local target_port="$2"
    local test_interval="${3:-1}"
    local test_timeout="${4:-1}"

    local cmd_out
    local status_icon

    while true; do
        if cmd_out="$(nc -zvw"$test_timeout" "$target_host" "$target_port" 2>&1)"; then
            status_icon="\xf0\x9f\x9f\xa2"
        else
            status_icon="\xf0\x9f\x94\xb4"
        fi
        printf " %b  %s\n" "${status_icon}" "${cmd_out}"
        sleep "$test_interval"
    done
}
# shortcut/aliases
function sshcheck () {
    if [[ $# -ne 1 ]]; then
        echo 'sshcheck: error: takes exactly 1 argument' >&2
        return 1
    fi
    portping "$1" 22 1 3
}
