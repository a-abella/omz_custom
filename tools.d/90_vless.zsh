function vless () {
    "$(find /usr/share/vim/vim*/macros -name "less.sh" -print | sort -n | tail -n1)" $@
}
compdef "_files" vless
