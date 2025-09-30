prefixer() {
  local prefix="$1"

  if [[ -z "$prefix" ]]; then
    echo "Usage: prefixer <prefix>" >&2
    return 1
  fi

  # Force line-buffered output from the upstream command
  stdbuf -oL -eL awk -v p="$prefix" '{print p " | " $0}'
}

