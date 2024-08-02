# looper
function loop () {
  sec=1
  if  [ ! -z "${1##*[!1-9]*}" ] 2>/dev/null; then
    sec="$1"
    shift
  fi
  while true; do
    eval $@
    sleep $sec
    printf -- '--- %.0s'  {1..$(($COLUMNS / 4))} ; echo
  done
}
# while+loop=woop
alias woop=loop
