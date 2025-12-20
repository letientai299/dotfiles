#!/bin/sh
# Show git root dir name when the depth from it to the working dir is too high
# Uses STARSHIP_GIT_ROOT env var (cached by zsh precmd) to avoid git calls

DEPTH_LIMIT=3

# Use cached git root from env var, fallback to git command
git_root="${STARSHIP_GIT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -z "$git_root" ] && exit 0

# Get current directory
cwd=$(pwd)

# Calculate depth from git root to current directory
relative_path="${cwd#$git_root}"
[ "$relative_path" = "$cwd" ] && exit 0

# Count directory depth (number of slashes after git root)
depth=$(printf '%s' "$relative_path" | tr -cd '/' | wc -c | tr -d ' ')

# Show git root name if depth exceeds limit
if [ "$depth" -ge "$DEPTH_LIMIT" ]; then
  printf "[%s]" "${git_root##*/}"
fi
