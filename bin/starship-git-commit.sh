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
    # Keep output ANSI-free; Starship escapes ANSI by default.
    # (Readable separator without hard-coded colors.)
    printf 'WIP%s · %s' "${msg#???}" "$time"
    ;;
  *)
    # Message with time separated by · for better readability
    printf '%s · %s' "$msg" "$time"
    ;;
esac
