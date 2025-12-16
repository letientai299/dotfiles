#!/bin/sh
# Fast custom segment: last git commit message with relative time
# Optimized: uses sh instead of zsh, single git call, minimal processing

# Single git call for both subject and relative time
info=$(git log -1 --pretty=format:'%s|%cr' 2>/dev/null) || exit 0
[ -z "$info" ] && exit 0

# Split on pipe
msg="${info%|*}"
time="${info#*|}"

# Truncate message if too long (POSIX way)
if [ ${#msg} -gt 40 ]; then
  msg="$(printf '%.37s' "$msg")..."
fi

# Check for WIP (case insensitive via pattern)
case "$msg" in
  [Ww][Ii][Pp]*)
    # WIP in orange (208), rest dim
    printf '\033[38;5;208mWIP\033[0m%s \033[2m(%s)\033[0m' "${msg#???}" "$time"
    ;;
  *)
    printf '%s \033[2m(%s)\033[0m' "$msg" "$time"
    ;;
esac
