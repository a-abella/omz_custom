alias lla="ll -a"
alias l='lla'
alias ccat='pygmentize -g -O style=nord-darker'

function cless () {
  ccat "$@" | less -R
}

# while+loop=woop
alias woop=loop

# k8s stuff
alias kdumpall="kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found --all-namespaces"
alias kcuncc="kubectl config unset current-context"
