# looper
function kdloop () {
  IFS=$'\n' _k_api_resources=( $(kubectl api-resources --verbs=list -o name) )
  if  [[ -n "$1"i ]] && (( "${_k_api_resources[(Ie)$1]}" )) ; then
    wl="$1"
    shift
  else
    >&2 echo "err: missing valid api-resource"
    return 1
  fi
  kubectl get "$wl" -o name | while read -r o; do
    >&2 echo -e "==========\n$o\n==========\n"
    kubectl describe "$o"
  done
}
function _kdloop () {local -a arguments ; IFS=$'\n' arguments=( ${_k_api_resources} ); _describe 'values' arguments ;}
compdef _kdloop kdloop
