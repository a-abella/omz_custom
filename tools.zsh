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

# stateful tools will put their configs in ~/.config
mkdir -p "$HOME/.config"

# define iterm2 statusbar component strings
function iterm2_print_user_vars () {
  iterm2_set_user_var kcontext "${_KUBE_CONTEXT:+${_KUBE_CONTEXT} }"
  iterm2_set_user_var awsprofile "${_AWS_PROFILE:+${_AWS_PROFILE} }"
  iterm2_set_user_var azuresub "${_AZURE_SUBSCRIPTION:+${_AZURE_SUBSCRIPTION} }"
}
# loop in bg to keep these vars set
# FIXME: doesn't work
#while true; do
#  source_kube_context
#  source_aws_profile
#  source_azure_subscription
#  iterm2_print_user_vars
#  sleep 5
#done >/dev/null 2>&1 &

