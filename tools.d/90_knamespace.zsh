###
### knamespace - kubectl context namespace manager
###

CONTEXT_SOURCE="${KUBECONFIG:-"$HOME/.kube/config"}"

function knamespace () {

  IFS=$'\n' local valid_namespaces=( $( kubectl --kubeconfig "$CONTEXT_SOURCE" get namespaces -o name | sed 's/^namespace\///' ) )
  
  usage (){
    echo "Usage: knamespace (-l/--list) [NAMESPACE]"
    echo
    echo "A kubectl namespace manager"
    echo
    echo "Options:"
    echo "  -c, --current-namespce  Prints the currently selected namespace"
    echo "  -l, --list              List all existing namespaces in the"
    echo "                           current context"
    echo
    echo "Arguments:"
    echo "  NAMESPACE      Name of the namespace to set"
    echo
  }

  if [[ "$#" -gt 1 ]]; then
    echo "error: incorrect number of arguments"
    echo
    usage
    return
  fi

  list_namespaces() {
    printf '%s\n' "${valid_namespaces[@]}"
  }

  validate_namespace() {
    if ! (( ${valid_namespaces[(Ie)$namespace]} )); then
      echo "error: invalid namespace name"
      echo
      usage
      return 1
    fi
  }

  get_namespace() {
    kubectl --kubeconfig "$CONTEXT_SOURCE" config view --minify -o jsonpath='{..namespace}'; echo
  }

  set_namespace() {
    kubectl --kubeconfig "$CONTEXT_SOURCE" config set-context --current --namespace="$namespace" > /dev/null
    echo "using namespace '$namespace'"
  }

  case "$1" in
    -c|--current-namespace)
      get_namespace
      return
    ;;
    -l|--list)
      list_namespaces
      return
    ;;
    -h|--help)
      usage
      return
    ;;
    *)
      local namespace="$1"
      if validate_namespace ; then
        set_namespace
      fi
      return
    ;;
  esac
}
# knamespace completion
function _knamespace () { local -a arguments ; IFS=$'\n' arguments=( --current-namespace --list $(kubectl --kubeconfig "$CONTEXT_SOURCE" get namespaces -o name | sed 's/^namespace\///') ) ; _describe 'values' arguments ; }
compdef _knamespace knamespace
###
### knamespace - END
###
