# pipe output to `slim` to truncate to the width of the terminal
function slim() {
    cut -c 1-$(tput cols)
}
