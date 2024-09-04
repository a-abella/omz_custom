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
          if [[ -n "$2" ]]; then
            cmd="chroma --style=nord --formatter=terminal16m --lexer=$2"    
          else
            cmd="chroma --style=nord --formatter=terminal16m"
          fi
          ;;
        pygmentize)
          if [[ -n "$2" ]]; then
            cmd="pygmentize -O style=nord -f terminal16m -l $2"
          else
            cmd="pygmentize -g -O style=nord -f terminal16m"
          fi
          ;;
        *)
          echo -e "ccat: error: invalid formatter '$CCAT_FORMATTER', must be 'chroma' or 'pygmentize'\n" >&2
          return 1
          ;;
      esac
      validate_formatter "$1" || return 1
    }
    
    local lang
    if [[ "$@[(I)-l|--lang]" -gt 0 && -n "$@[$@[(I)-l|--lang]+1]" ]]; then
      lang="${@[$@[(I)-l|--lang]+1]}"
      unset "argv[(I)$lang]"
      unset "argv[(I)-l|--lang]"
    fi
    
    local files=()
    local flags=()
    local arg
    for arg in $@; do
      if [[ "$arg" = "-"* ]]; then
        flags+=( "$arg" )
      else
        files+=( "$arg" )
      fi
    done
    
    # default to pygmentize
    set_formatter "${CCAT_FORMATTER:-pygmentize}" "$lang" || return 1
    
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
    local lang lang_arg
    if [[ "$@[(I)-l|--lang]" -gt 0 && -n "$@[$@[(I)-l|--lang]+1]" ]]; then
      lang="${@[$@[(I)-l|--lang]+1]}"
      unset "argv[(I)$lang]"
      unset "argv[(I)-l|--lang]"
    fi
    if [[ -n "$lang" ]]; then
      lang_arg=("--lang" "$lang")
    fi
  
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
      hold="$(ccat $lang_arg "$files")"
      if [[ -n "$hold" ]]; then
        # the {} and sleep is needed to handle a screen buffer piping issue
        { sleep 0.01; echo -e "$hold" ;} | less -R $flags
      fi
    else 
      ccat $lang_arg | less -R $flags
    fi
}
compdef _less cless
