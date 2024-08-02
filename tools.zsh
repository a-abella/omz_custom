tools_d="$HOME/.oh-my-zsh/custom/tools.d"
if [[ -d "$tools_d" ]]; then
  local _file
  for _file in "$tools_d"/* ; do
    source "$_file"
  done
  unset _file
fi

function sshcheck() {
    while true; do
        nc -zvw1 $1 22;
        sleep 1;
    done
}

