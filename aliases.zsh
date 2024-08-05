# simple aliases
#   functions should go in tools.zsh or tools.d/*.zsh

alias lla="ll -a"
alias l='lla'

alias tmux='tmux -f "$TMUX_CONF"'

# k8s stuff
alias kdumpall="kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found --all-namespaces"
alias kcuncc="kubectl config unset current-context"
