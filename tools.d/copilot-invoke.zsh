AGENT_COUNTER_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/copilot-session-count"
AGENT_WARN_AFTER="${AGENT_WARN_AFTER:-20}"
AGENT_MAX_PROMPT_CHARS="${AGENT_MAX_PROMPT_CHARS:-2000}"

'copilot-invoke' () {
    local new_session=0

    if [[ "$1" == "--new" ]]; then
        new_session=1
        shift
    fi

    # Guard against huge prompts
    local prompt="$*"
    if (( ${#prompt} > AGENT_MAX_PROMPT_CHARS )); then
        echo "✋ Prompt is ${#prompt} chars (max $AGENT_MAX_PROMPT_CHARS). Refusing to send." >&2
        return 1
    fi

    # Session counter
    mkdir -p "$(basename "$AGENT_COUNTER_FILE")"
    if (( new_session )); then
        echo 0 > "$AGENT_COUNTER_FILE"
    else
        local count=$(cat "$AGENT_COUNTER_FILE" 2>/dev/null || echo 0)
        count=$(( count + 1 ))
        echo "$count" > "$AGENT_COUNTER_FILE"
        if (( count % AGENT_WARN_AFTER == 0 )); then
            echo "⚠ $count agent turns in this session. Use '@ --new ...' to start fresh." >&2
        fi
    fi

    if (( new_session )); then
        copilot -p "$prompt"
    else
        copilot --continue -p "$prompt"
    fi
}
alias @='copilot-invoke'
