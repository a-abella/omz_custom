# simple aliases
#   functions should go in tools.zsh or tools.d/*.zsh
#   unfunction and unlias declarations can go here


# unfunctions - disable nuisance built-in functions
unfunction work_in_progress
# unfunctions end

# unaliases - disable built-in aliases, usually for overriding with functions
unalias kcn
# unaliases end

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

## navigation
alias omz_custom="cd $ZSH_CUSTOM"
# condensers end

# command overrides
alias tmux='tmux -f "$TMUX_CONF"'
# command overrides end

# oneline funcs
alias mtime='_mtime(){ local TIMEFMT="%J  %mU user %mS system %P cpu %mE total"; time $@; unset _mtime; }; _mtime'
# oneline funcs end

# k8s stuff
alias kdumpall="kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found --all-namespaces"
alias kcuncc="kubectl config unset current-context"
alias kctx="kcontext"
alias kcn="knamespace"
alias kns="knamespace"
# k8s stuff end
