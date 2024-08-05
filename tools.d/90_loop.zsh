# looper
function loop () {
  sec=1
  if  [[ "$1" = <-> ]] ; then
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
