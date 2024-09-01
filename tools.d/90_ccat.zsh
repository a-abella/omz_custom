function ccat () {
    local cmd
    
    validate_formatter () {
        if ! command -v "$1" &>/dev/null; then
            echo -e "ccat: error: selected formatter '$1' not found\n" >&2
            return 1
        fi
    }

    set_formatter () {
        case "$1" in
            chroma)
                cmd="chroma --style=nord --formatter=terminal16m"
            ;;
            pygmentize)
                cmd="pygmentize -g -O style=nord -O formatter=terminal16m"
            ;;
            *)
                echo -e "ccat: error: invalid formatter '$CCAT_FORMATTER', must be 'chroma' or 'pygmentize'\n" >&2
                return 1
            ;;
        esac
        validate_formatter "$1" || return 1
    }
    # default to pygmentize
    set_formatter "${CCAT_FORMATTER:-pygmentize}" || return 1
    
    local files=()
    local flags=()
    local arg
    for arg in $@; do
      [[ "$arg" = "-"* ]] && flags+=( "$arg" ) || files+=( "$arg" )
    done
    if (( "${#files}" > 0 )); then
      local file
      for file in $files; do
        if [[ -f "$file" || -p "$file" ]]; then
          eval $cmd "$file" | cat $flags
        elif [[ -d "$file" ]]; then
          echo -e "ccat: error: '$file' is a directory\n" >&2
          return 1
        else
          echo -e  "ccat: error: file '$file' not found\n" >&2
          return 1
        fi
      done
    else
      eval $cmd | cat $flags
    fi 
}
compdef _cat ccat
function cless () {
    local files=()
    local flags=()
    local arg
    for arg in $@; do
      [[ "$arg" = "-"* ]] && flags+=( "$arg" ) || files+=( "$arg" )
    done
    if (( "${#files}" > 0 )); then
      if (( "${#files}" > 1 )); then
        echo "cless: error: too many file arguments" >&2
        return 1
      fi
      local hold
      hold="$(ccat "$files")"
      if [[ -n "$hold" ]]; then
        # the {} and sleep is needed to handle a screen buffer piping issue
        { sleep 0.01; echo -e "$hold" ;} | less -R $flags
      fi
    else 
      ccat | less -R $flags
    fi
}
compdef _less cless
