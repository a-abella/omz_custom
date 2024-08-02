###
### dotenv - .env file manager
###
function dotenv() {
    local env_file=".env"
    local command key value
    local -A zopts

    # Option parsing using zparseopts
    zparseopts -D -E -A zopts - \
        f: -file: \
        h -help || return 1

    # Handle help option first
    if [[ -v zopts[-h] || -v zopts[--help] ]]; then
        echo "Usage: dotenv [-f | --file <env_file>] <command> [arguments]"
        echo "Commands:"
        echo "  list [--keys]       List all key-value pairs, or just keys with --keys"
        echo "  get <key>           Get the value for the specified key"
        echo "  set <key=value>     Set or update the specified key with a value"
        return 0  # Exit after showing help
    fi

    if [[ -n "${zopts[-f]}" ]]; then
        env_file="${zopts[-f]}"
    elif [[ -n "${zopts[--file]}" ]]; then
        env_file="${zopts[--file]}"
    fi

    # Ensure there is a command to process
    if [[ $# -gt 0 ]]; then
        command=$1
        shift
    else
        echo -e "Error: No command provided.\n"
        dotenv -h
        return 1
    fi

    # Check if the env file exists
    if [[ ! -f $env_file ]]; then
        echo -e "Error: File '$env_file' does not exist.\n"
        dotenv -h
        return 1
    fi

    case $command in
        list)
            # Handle the --keys flag manually
            if [[ $# -gt 0 && $1 == "--keys" ]]; then
                shift
                while IFS='=' read -r key _; do
                    echo "$key"
                done < "$env_file"
            else
                cat "$env_file"
            fi
            ;;
        get)
            key=$1
            while IFS='=' read -r k v; do
                if [[ $k == "$key" ]]; then
                    echo "${(Q)v}"
                    return 0
                fi
            done < "$env_file"
            ;;
        set)
            key=${1%%=*}
            value=${1#*=}
            local temp_file=$(mktemp)

            if [[ "$value" == *"\\" ]]; then
                value="${value//\\/\\\\}"
            fi
            if [[ "$value" == *'"'* ]]; then
                value="${value//\"/\\\"}"
            fi
            if [[ "$value" == *" "* ]]; then
                value="\"${value}\""
            fi

            local found=0
            while IFS='=' read -r k v; do
                if [[ $k == "$key" ]]; then
                    echo "$key=$value" >> "$temp_file"
                    found=1
                else
                    echo "$k=$v" >> "$temp_file"
                fi
            done < "$env_file"

            if [[ $found -eq 0 ]]; then
                echo "$key=$value" >> "$temp_file"
            fi

            mv "$temp_file" "$env_file"
            ;;
        *)
            echo -e "Error: Invalid command '$command'. \n"
            dotenv -h
            return 1
            ;;
    esac
}

# The completion function for `dotenv`
compdef _dotenv dotenv

function _dotenv() {
    local state

    _arguments -s \
        '-f[specify the env file]:env_file:_files' \
        '--file[specify the env file]:env_file:_files' \
        '-h[display help]' \
        '--help[display help]' \
        '1:command:(list get set)' \
        '2:variable name:->varname' \
        && return 0

    case $state in
        (varname)
            if [[ -s "${1:-.env}" ]]; then
              if [[ $words[2] == "get" ]]; then
                _values "variable names" ${(f)"$(awk -F= '{print $1}' ${1:-.env})"}
              elif [[ $words[2] == "set" ]]; then
                _values "variable names" ${(f)"$(awk -F= '{print $1 "="}' ${1:-.env})"}
              elif [[ $words[2] == "list" ]]; then
                _values "variable names" "--keys"
              fi
            else
              _values "variable names" ""
            fi
          ;;
    esac
}
###
### dotenv - END
###
