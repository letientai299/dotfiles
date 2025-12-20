#!/bin/sh
# Fast custom segment: last git commit message with relative time
# Optimized: uses sh instead of zsh, single git call, minimal processing

# Single git call for subject
msg=$(git log -1 --pretty=format:'%s' 2>/dev/null) || exit 0
[ -z "$msg" ] && exit 0

is_wip=0
rest="$msg"

case "$rest" in
[Ww][Ii][Pp]*)
  is_wip=1
  rest="${rest#???}"
  # Trim common separators after WIP
  rest="${rest# }"
  rest="${rest#:}"
  rest="${rest# }"
  rest="${rest#-}"
  rest="${rest# }"
  ;;
esac

max_total=70

if [ "$is_wip" -eq 1 ]; then
  prefix="WIP"
  if [ -n "$rest" ]; then
    # Keep total length <= $max_total including "WIP "
    allowed=$((max_total - ${#prefix} - 1))
    if [ $allowed -gt 0 ] && [ ${#rest} -gt $allowed ]; then
      if [ $allowed -gt 3 ]; then
        rest="$(printf "%.${allowed}s" "$rest")"
        rest="$(printf "%.$((allowed - 3))s" "$rest")..."
      else
        rest=""
      fi
    fi
    # Bold orange (256-color 208) WIP label; reset so the rest uses normal prompt color
    printf '\033[1;38;5;208m%s\033[0m %s' "$prefix" "$rest"
  else
    printf '\033[1;38;5;208m%s\033[0m' "$prefix"
  fi
else
  # Non-WIP: truncate to $max_total chars
  if [ ${#msg} -gt $max_total ]; then
    msg="$(printf '%.32s' "$msg")..."
  fi
  printf '%s' "$msg"
fi
