function ccat () {
    local cmd
    if command -v pygmentize &>/dev/null; then
        cmd="pygmentize -g -O style=nord-darker"
    elif command -v chroma &>/dev/null; then
        cmd="chroma --style=dracula --formatter=terminal256"
    else
        echo "error: pygmentize or chroma not in path" >&2
        return 1
    fi
    if [[ -f "$@[-1]" ]]; then
        local file="$@[-1]"
        eval $cmd "$file"
    else
        cat | eval $cmd
    fi
}
function cless () {
    # TODO: handle flags before or after file
    case "$@[-1]" in
        -*|"")
            ccat | less -R $@
        ;;
        *)
            if [[ -f "$@[-1]" ]]; then
                local file="$@[-1]"
                ccat "$file" | less -R ${@[@]:1:-1}
            else
                echo "error: file not found: $file" >&2
                return 1
            fi
        ;;
    esac
}
compdef _less cless

