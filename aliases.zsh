# simple aliases
#   functions should go in tools.zsh or tools.d/*.zsh
#   unfunction and unlias declarations can go here


# ZIM - not needed
# unfunctions - disable nuisance built-in functions
#unfunction work_in_progress
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
## base64
alias be='base64'
alias bd='base64 -d'
## pbcopy
alias pbc='pbcopy'
alias pbp='pbpaste'
## exit code
alias '?'='echo $?'
## navigation
alias omz_custom="cd $ZSH_CUSTOM"
# condensers end

# command overrides
alias tmux='tmux -f "$TMUX_CONF"'
alias pbcopy="perl -0 -pe 's/\n\Z//' | pbcopy"   # strips trailing newlines from pbcopy input
# command overrides end

# oneline funcs
alias mtime='_mtime(){ local TIMEFMT="%J  %mU user %mS system %P cpu %mE total"; time $@; unset _mtime; }; _mtime'
alias shuid='_shuid(){ python3 -c "import random; print(\"\".join( [ x.lower() if random.randint(0,1) else x for x in \"$(uuidgen |  head -c12 | tail -c9 | tr A-Z a-z)\" ] ))"; }; _shuid'
# oneline funcs end

# k8s stuff
alias kg='kubectl get'
alias kd='kubectl describe'
alias kggw='kubectl get gateway'
alias kdgw='kubectl describe gateway'
alias kgsm='kubectl get servicemonitors.monitoring.coreos.com'
alias kgsma='kubectl get servicemonitors.monitoring.coreos.com -A'
alias kdsm='kubectl describe servicemonitors.monitoring.coreos.com'
alias kgpm='kubectl get podmonitors.monitoring.coreos.com'
alias kgpma='kubectl get podmonitors.monitoring.coreos.com -A'
alias kdpm='kubectl describe podmonitors.monitoring.coreos.com'
alias kgcrd='kubectl get crd'
alias kdumpall="kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found --all-namespaces"
alias kcuncc="kubectl config unset current-context"
alias kctx="kcontext"
alias kcn="knamespace"
alias kns="knamespace"
alias kaliases="alias | egrep --color=none '^k'"
alias ktn="kubectl top nodes"
alias ktnc="kubectl top nodes --sort-by cpu"
alias ktnm="kubectl top nodes --sort-by memory"
alias ktp="kubectl top pods"
alias ktpc="kubectl top pods --sort-by cpu"
alias ktpm="kubectl top pods --sort-by memory"
alias kgcmy="kubectl get configmaps -o yaml"
# k8s stuff end

# git stuff
alias groot='cd "$(git rev-parse --show-toplevel || echo .)"'
# git stuff end
