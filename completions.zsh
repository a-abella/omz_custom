# for any cmds (usually installed by brew) that do
# not auto-source completions from $FPATH, completion
# sourcing can be done here.

source $(brew --prefix)/etc/bash_completion.d/az
source <(fzf --zsh)
