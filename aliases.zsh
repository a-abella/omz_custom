# simple aliases
#   functions should go in tools.zsh or tools.d/*.zsh

# condensers
## ls
alias l='ll'
alias la='ll -a'
alias lr='ll -R'
alias lar='ll -aR'
alias lla="ll -a"
alias llr='ll -R'
alias llar='ll -aR'
## grep
alias igrep='grep -i'
alias eigrep='egrep -i'

# azure
alias azss='az account set --subscription'

# command overrides
alias tmux='tmux -f "$TMUX_CONF"'

# oneline funcs
alias mtime='_mtime(){ local TIMEFMT="%J  %mU user %mS system %P cpu %mE total"; time $@; unset _mtime; }; _mtime'

# k8s stuff
alias kdumpall="kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found --all-namespaces"
alias kcuncc="kubectl config unset current-context"
alias kcontext="kubectl config use-context"
