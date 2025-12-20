#!/bin/sh
# Show git root dir name when the depth from it to the working dir is too high

DEPTH_LIMIT=3

# Get git root directory
git_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$git_root" ]; then
  exit 0
fi

# Get current directory
cwd=$(pwd)

# Calculate depth from git root to current directory
relative_path="${cwd#$git_root}"
if [ "$relative_path" = "$cwd" ]; then
  # Not in git root path
  exit 0
fi

# Count directory depth (number of slashes after git root)
depth=$(echo "$relative_path" | tr -cd '/' | wc -c | tr -d ' ')

# Show git root name if depth exceeds limit
if [ "$depth" -ge "$DEPTH_LIMIT" ]; then
  printf "[%s]" $(basename "$git_root")
fi
