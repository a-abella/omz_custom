###
### kcontext - aws context manager & sync
###

function kcontext () {
  
  local CONTEXT_SOURCE="${KUBECONFIG:-"$HOME/.kube/config"}"
  local ALIAS_FILE="${HOME}/.kube/kcontext_aliases"
  IFS=$'\n' local valid_contexts=( $( kubectl --kubeconfig "$CONTEXT_SOURCE" config get-contexts -o name ) )
  IFS=$'\n' local valid_aliases=( $(dotenv -f "$ALIAS_FILE" list-values) )
  
  usage (){
    echo "Usage: kcontext (-l/--list) [(-u/--unset) | (-a/--alias ALIAS | -ua/--unalias) CONTEXT]"
    echo
    echo "A kubectl context manager"
    echo
    echo "Options:"
    echo "  -c, --current-context           Prints the name (or alias if one is set) of the currently"
    echo "                                   selected context"
    echo "  -cr, --current-context-raw      Prints the name of the currently selected context, resolving"
    echo "                                   any alias to the actual context name"
    echo "  -l, --list                      Lists the available context names (or aliases if set) from"
    echo "                                   kubeconfig"
    echo "  -lr, --list-raw                 Lists the available context names from kubeconfig, resolving"
    echo "                                   any alias to the actual context name"
    echo "  -la, --list-aliases             Lists available context aliases"
    echo "  -u, --unset                     Sets the active context to a null entry, and inserts the null"
    echo "                                   entry to the kubeconfig if one is not found. Selected by"
    echo "                                   default if no other arugments are supplied"
    echo "  -a ALIAS, --alias ALIAS         Sets an alias for the CONTEXT, such that all occurrences of"
    echo "                                   the context (when listing or in shell prompt) will be"
    echo "                                   replaced with the ALIAS name. If no CONTEXT is supplied,"
    echo "                                   the current context is used. Only one alias may be set per"
    echo "                                   context"
    echo "  -ua CONTEXT, --unalias CONTEXT  Unsets the alias for the specified CONTEXT, if it exists. If"
    echo "                                   no CONTEXT is supplied, the current context is used"
    echo
    echo "Arguments:"
    echo "  CONTEXT        Name of the context or context-alias to use"
    echo
    echo "Examples:"
    echo "  Switch to context named \"local\""
    echo "   ~$ kcontext local"
    echo "  Unset your context"
    echo "   ~$ kcontext  # (no context provided unsets the current context)"
    echo "   ~$ kcontext --unset"
    echo "  Alias context named \"very-long-context\" to \"my-alias\""
    echo "   ~$ kcontext --alias my-alias very-long-context"
    echo "   ~$ kcontext --alias my-alias  # (no context provided aliases the current context)"
    echo "  Remove alias from very-long-context"
    echo "   ~$ kcontext --unalias very-long-context"
    echo "   ~$ kcontext --unalias  # (no context provided unaliases the current context)"
    echo
    echo "Notes:"
    echo "  kubectl will _not_ recognize the alias as a valid context name, such "
    echo "   as when passed to \`kubectl --context \$ALIAS\`; for this scenario"
    echo "   use the raw context names provided by \`kcontext --list-raw\`."
    echo "   Aliases are only recognized and resolved by this custom Zsh environment."
    echo
  }

  # this sucks, rewrite this
  local -A argcounts
  argcounts=(
    [-c_lower]=1 [-c_upper]=1 [--current-context_lower]=1 [--current-context_upper]=1
    [-cr_lower]=1 [-cr_upper]=1 [--current-context-raw_lower]=1 [--current-context-raw_upper]=1
    [-l_lower]=1 [-l_upper]=1 [--list_lower]=1 [--list_upper]=1
    [-lr_lower]=1 [-lr_upper]=1 [--list-raw_lower]=1 [--list-raw_upper]=1
    [-la_lower]=1 [-la_upper]=1 [--list-aliases_lower]=1 [--list-aliases_upper]=1
    [-u_lower]=1 [-u_upper]=1 [--unset_lower]=1 [--unset_upper]=1
    [-a_lower]=2 [-a_upper]=3 [--alias_lower]=2 [--alias_upper]=3
    [-ua_lower]=1 [-ua_upper]=2 [--unalias_lower]=1 [--unalias_upper]=2
  )
  if [[ -n "${argcounts[${1}_lower]}" ]]; then
    if [[ "$#" -lt "${argcounts[${1}_lower]}" || "$#" -gt "${argcounts[${1}_upper]}" ]]; then
      echo "error: invalid number of arguments"
      echo
      return 1
    fi
  fi

  list_contexts() {
    local ctx als
    local -a list
    local -a alias_map
    IFS=$'\n' alias_map=( $(dotenv -f "$ALIAS_FILE" list) )
    for ctx in $valid_contexts; do
      als=""
      for pair in $alias_map; do
        if [[ "$pair" =~ ^([^=]+)=(.*)$ ]]; then
          if [[ "$ctx" == "${match[1]}" ]]; then
            als="${match[2]}"
            break
          fi
        fi
      done
      list+=( "${als:-$ctx}" )
    done
    printf '%s\n' ${list[@]} | grep -v 'none'
  }

  list_contexts_raw() {
    printf '%s\n' ${valid_contexts[@]} | grep -v 'none'
  }
  list_aliases() {
    dotenv -f "$ALIAS_FILE" list
  }

  validate_context() {
    local ctx="$1"
    if ! (( ${valid_contexts[(Ie)$ctx]} )); then
      echo "error: invalid context name"
      echo
      return 1
    fi
  }
  validate_alias() {
    local als="$1"
    if ! (( ${valid_aliases[(Ie)$als]} )); then
      # echo "error: invalid alias name"
      # echo
      return 1
    fi
  }

  get_context() {
    local ctx als
    ctx="$(kubectl --kubeconfig "$CONTEXT_SOURCE" config current-context)"
    als="$(dotenv -f "$ALIAS_FILE" get "$ctx")"
    echo "${als:-$ctx}"
  }
  get_context_raw() {
    kubectl --kubeconfig "$CONTEXT_SOURCE" config current-context
  }

  set_context() {
    local ctx="$1"
    if (( ${valid_aliases[(Ie)$ctx]} )); then
      local -a alias_map
      IFS=$'\n' alias_map=( $(dotenv -f "$ALIAS_FILE" list) )
      # get context from alias where map contains context=alias
      for pair in $alias_map; do
        if [[ "$pair" =~ ^([^=]+)=(.*)$ ]]; then
          if [[ "$ctx" == "${match[2]}" ]]; then
            ctx="${match[1]}"
            break
          fi
        fi
      done
    fi
    kubectl --kubeconfig "$CONTEXT_SOURCE" config use-context "$ctx" > /dev/null
    echo "using context '$ctx'"
  }

  unset_context() {
    
    if kubectl --kubeconfig "$CONTEXT_SOURCE" config use-context none &> /dev/null ; then
      echo "unset context"
      return
    fi
    if ! command -v yq &> /dev/null ; then
      echo "error: null context not found, and 'yq' command not found for null context insertion"
      echo
      return 1
    fi
    # inject a null context if one doesn't exist already, and yq is available
    yq -i '.contexts += [{"context":{"cluster":"", "user":""},"name":"none"}]' ~/.kube/config
    kubectl --kubeconfig "$CONTEXT_SOURCE" config use-context none > /dev/null
    echo "unset context"
  }
  
  alias_context() {
    local als="$1"
    local ctx="$2"
    # if als in valid_aliases, then error
    if (( ${valid_aliases[(Ie)$als]} )); then
      echo "error: alias '$als' already exists"
      return 1
    fi
    local _als="$(dotenv -f "$ALIAS_FILE" get "$ctx")"
    if [[ -n "$_als" ]]; then
      echo "error: contex '$ctx' already has an alias '$_als'"
      echo
      return 1
    fi
    dotenv -f "$ALIAS_FILE" set "$ctx=$als"
    echo "alias '$als' set for context '$ctx'"
  } 
  
  unalias_context() {
    local ctx="$1"
    if (( ! ${valid_contexts[(Ie)$ctx]} )); then
      echo "error: invalid context name"
      echo
      return 1
    fi
    local -a aliased_contexts
    IFS=$'\n' aliased_contexts=( $(dotenv -f "$ALIAS_FILE" list-keys) )
    if ! (( ${aliased_contexts[(Ie)$ctx]} )); then
      echo "error: context '$ctx' has no alias"
      echo
      return 1
    fi
    local als="$(dotenv -f "$ALIAS_FILE" get "$ctx")"
    dotenv -f "$ALIAS_FILE" unset "$ctx"
    echo "alias '$als' for context '$ctx' removed"
  }

  case "$1" in
    -c|--current-context)
      get_context
      return
    ;;
    -cr|--current-context-raw)
      get_context_raw
      return
    ;;
    -l|--list)
      list_contexts
      return
    ;;
    -lr|--list-raw)
      list_contexts_raw
      return
    ;;
    -la|--list-aliases)
      list_aliases
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
    -a|--alias)
      shift
      local alias="$1"
      local context="${2:-$(kcontext --current-context-raw)}"
      if validate_context "$context" ; then
        alias_context "$alias" "$context"
      fi
      return
    ;;
    -ua|--unalias)
      shift
      local context="${1:-$(kcontext --current-context-raw)}"
      unalias_context "$context"
      return
    ;;
    -*)
      echo "error: invalid option"
      echo
      return 1
    ;;
    *)
      local context="$1"
      if validate_alias "$context" ; then
        set_context "$context"
      elif validate_context "$context" ; then
        set_context "$context"
      fi
      return
    ;;
  esac
}
# kcontext completion
function _kcontext () {
  local ALIAS_FILE="${HOME}/.kube/kcontext_aliases"
  local state line
  local -i ret
  ret=1
  _arguments -C \
    '1: :->cmds' \
    '*:: :->args' && ret=0
  
  case $state in
    cmds)
      local vals
      vals=( $(kcontext --list) )
      if [[ "$line[1]" == -* ]]; then
        vals=(
              -h --help
              -c --current-context
              -cr --current-context-raw
              -l --list
              -lr --list-raw
              -la --list-aliases
              -u --unset
              -a --alias
              -ua --unalias
            )
      fi            
      _values 'kcontext command' $vals
      ret=0
    ;;
    args)
      case $line[1] in
        -a|--alias)
          if (( ${#line} == 3 )); then
            _values 'context name' $(kcontext --list-raw)
            ret=0
          fi
        ;;
        -ua|--unalias)
          if (( ${#line} == 2 )); then
            local vals
            vals=( $(dotenv -f "$ALIAS_FILE" list-keys | sort) )
            if (( ${#vals} )); then
              _values 'alias name' $vals
              ret=0
            fi
          fi
        ;;
      esac
    ;;
  esac
  return $ret
}
compdef _kcontext kcontext
###
### kcontext - END
###
