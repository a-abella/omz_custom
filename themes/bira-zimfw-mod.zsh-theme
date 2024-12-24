# vim:et sts=2 sw=2 ft=zsh

typeset -g VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

# Depends on git-info module to show git information
typeset -gA git_info
if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format '%c'
  zstyle ':zim:git-info:dirty' format ' %F{red}●%F{#ffcc66}'
  zstyle ':zim:git-info:keys' format \
      'prompt' ' %F{#ffcc66}%D %b%c'
  add-zsh-hook precmd git-info
fi

# Depends on prompt-pwd module to show pwd information
zstyle ':zim:prompt-pwd:tail' length 3

# Depends on custom kcontext/knamespace tooling
add-zsh-hook precmd source_kube_context

PS1='╭─%B%(?.%F{green}.%F{red}) %F{blue}$(prompt-pwd)${_KUBE_CONTEXT:+" %F{#939c9e}${_KUBE_CONTEXT}"}${(e)git_info[prompt]}${VIRTUAL_ENV:+" %F{green} ${VIRTUAL_ENV:t}"}%f%b
╰─%B%(!.#.$)%b '
RPS1='%B%(?..%F{red}%? ↵%f)%b'
