###
### flatter - flatten projects to single text stream
###

function flatter () {


  _usage (){
      echo "Usage: flatter (-r/--redact [LEVEL]) (-w/--write [FILE]) [PATH]"
    echo
    echo "Flattens project files to a single text output stream"
    echo
    echo "Options:"
    echo "  -d, --disable-redact   Disable content redaction"
    echo "  -r, --redact [LEVEL]   Sets the confidence level for the \`redact\` command,"
    echo "                          see \`redact --help\` for more info; defaults to 'med'"
    echo "  -w, --write [FILE]     Location to write outout stream; defaults to stdout"
    echo
    echo "Arguments:"
    echo "  PATH       Path to file or directory to generate output from; defaults to"
    echo "              the current directory"
    echo
  }


  _print_err() {
    echo "error: $*"
    echo
    _usage
  }


  local -A zopts
  if ! zparseopts -F -D -E -A zopts -- \
    h=help -help \
    d=disable_redact -disable-redact=disable_redact \
    r:=redact -redact:=redact \
    w:=write -write:=write ; then
      _print_err "unknown options" && return 1
  fi


  [[ -v zopts[--help] || -v zopts[-h] ]] && _usage && return
  [[ $# -gt 1 ]] && _print_err "too many paths" && return 1

  _CONFIDENCE_LEVEL="${zopts[--redact]:-${zopts[-r]:-med}}"
  _OUTPUT_PATH="${zopts[--write]:-${zopts[-w]:-/dev/stdout}}"
  _INPUT_PATH="${1:-.}"


  _flatten_input() {
    if [[ -d "$1" ]]; then
      find "$1" -type f -exec grep -Iq . {} \; -print0 | xargs -0 tail -n+1
    elif [[ -f "$1" ]]; then
      tail -n+1 "$1" /dev/null | grep -Fv '==> /dev/null <=='
    else
      _print_err "unknown PATH argument '$1'" && return 1
    fi
  }


  _redacter() {
    if [[ -v zopts[disable_redact] || -v zopts[--disable-redact] || -v zopts[-d] ]]; then 
      cat > "$_OUTPUT_PATH"
    else
      cat | redact --write "$_OUTPUT_PATH" --confidence "$1" --quiet
    fi
  }
  

  # run in subshell for pipefail behavior
  (_flatten_input "$_INPUT_PATH" | _redacter "$_CONFIDENCE_LEVEL")
  return $?
}

_flatter() {
  local -a options levels
  local curcontext="$curcontext" state state_descr line
  typeset -A opt_args

  options=(
    '-d[Disable content redaction]'
    '--disable-redact[Disable content redaction]'
    '-r[Set redaction level]:redaction level:(low med high)'
    '--redact[Set redaction level]:redaction level:(low med high)'
    '-w[Specify output file]:output file:_files'
    '--write[Specify output file]:output file:_files'
  )

  _arguments -s -S : \
    $options \
    '*:path:_files' \
    && return 0

  return 1
}

compdef _flatter flatter
