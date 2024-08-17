# source all tools.d/*.zsh
tools_d="$HOME/.oh-my-zsh/custom/tools.d"
if [[ -d "$tools_d" ]]; then
  setopt +o nomatch
  local _paths=( "$tools_d"/*.zsh "$tools_d"/*.sh )
  setopt nomatch
  local _file
  for _file in $_paths ; do
    [[ -s "$_file" ]] && source "$_file"
  done
  unset _file
  unset _paths
fi

