function ccat () {
    local cmd
    if command -v pygmentize &>/dev/null; then
        cmd="pygmentize -g -O style=nord-darker"
    elif command -v chroma &>/dev/null; then
        cmd="chroma --style=dracula --formatter=terminal256"
    else
        echo "error: pygmentize or chroma not in path" >&2
        return 1
    fi
    if (( "${#@}" > 0 )); then
      local file
      for file in "$@[@]"; do
        if [[ -f "$file" || -p "$file" ]]; then
          eval $cmd "$file"
        elif [[ -d "$file" ]]; then
          echo -e "ccat: error: '$file' is a directory\n" >&2
          return 1
        else
          echo -e  "ccat: error: file '$file' not found\n" >&2
          return 1
        fi
      done
    else
      eval $cmd
    fi 
}
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

