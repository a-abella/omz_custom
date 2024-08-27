###
### kcontext - aws context manager & sync
###

CONTEXT_SOURCE="${KUBECONFIG:-"$HOME/.kube/config"}"

function kcontext () {

  IFS=$'\n' local valid_contexts=( $( kubectl --kubeconfig "$CONTEXT_SOURCE" config get-contexts -o name ) )
  
  usage (){
    echo "Usage: kcontext (-l/--list) [(-u/--unset) | CONTEXT]"
    echo
    echo "A kubectl context manager"
    echo
    echo "Options:"
    echo "  -c, --current-context  Prints the name of the currently selected context"
    echo "  -l, --list             Lists the available context names from kubeconfig"
    echo "  -u, --unset            Sets the active context to a null entry, and inserts"
    echo "                          the null entry to the kubeconfig if one is not found."
    echo "                          Selected by default if no CONTEXT is supplied"
    echo
    echo "Arguments:"
    echo "  CONTEXT        Name of the context to set, sourced from kubeconfig"
    echo
  }

  if [[ "$#" -gt 1 ]]; then
    echo "error: incorrect number of arguments"
    echo
    usage
    return
  fi

  list_contexts() {
    printf '%s\n' "${valid_contexts[@]}" | grep -v 'none'
  }

  validate_context() {
    if ! (( ${valid_contexts[(Ie)$context]} )); then
      echo "error: invalid context name"
      echo
      usage
      return 1
    fi
  }

  get_context() {
    kubectl --kubeconfig "$CONTEXT_SOURCE" config current-context
  }

  set_context() {
    kubectl --kubeconfig "$CONTEXT_SOURCE" config use-context "$context" > /dev/null
    echo "using context '$context'"
  }

  unset_context() {
    kubectl --kubeconfig "$CONTEXT_SOURCE" config use-context none > /dev/null
    echo "unset context"
  }

  case "$1" in
    -c|--current-context)
      get_context
      return
    ;;
    -l|--list)
      list_contexts
      return
    ;;
    -h|--help)
      usage
      return
    ;;
    -u|--unset|"")
      unset_context
      return
    ;;
    *)
      local context="$1"
      if validate_context ; then
        set_context
      fi
      return
    ;;
  esac
}
# kcontext completion
function _kcontext() { local -a arguments ; IFS=$'\n' arguments=( --current-context --list --unset $( kubectl --kubeconfig "$CONTEXT_SOURCE" config get-contexts -o name ) ) ; _describe 'values' arguments ; }
compdef _kcontext kcontext
###
### kcontext - END
###
