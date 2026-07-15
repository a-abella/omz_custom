# random exports

# path
export PATH="$PATH:$HOME/.zsh_custom/bin"

# editor
export EDITOR="/usr/bin/vim"

# tmux conf location
export TMUX_CONF="$HOME/.zsh_custom/confs/tmux-custom.conf"

# set ccat formatter command
export CCAT_FORMATTER=chroma

# set LANG locale for CLI progs that care
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# unset aws-cli pager, default to no paging
export AWS_PAGER=

# set bedrock-proxy endpoints only for ssh session from local
if [[ "$SSH_CLIENT" == "192.168.1.25"* ]]; then
  export AWS_ACCESS_KEY_ID=AKIAFAKEACCESSKEYID00
  export AWS_SECRET_ACCESS_KEY=fakeSecretKey0000000000000000000000000000
  export AWS_ENDPOINT_URL_BEDROCK=http://desktop.home.lan:8123
  export AWS_ENDPOINT_URL_BEDROCK_RUNTIME=http://desktop.home.lan:8123
fi
