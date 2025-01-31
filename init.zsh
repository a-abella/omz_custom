# source all custom_d
custom_d="$HOME/.zsh_custom"
if [[ -d "$custom_d" ]]; then
  setopt +o nomatch
  local _c_paths=( "$custom_d"/{aliases,exports,tools}.zsh )
  setopt nomatch
  local _c_file
  for _c_file in $_c_paths ; do
    [[ -s "$_c_file" ]] && source "$_c_file"
  done
  unset _c_file
  unset _c_paths
fi
