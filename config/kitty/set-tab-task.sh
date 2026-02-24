#!/bin/bash
# Edit kitty tab task description for the current git project.
# Task file is a tempfile whose path is derived from the git dir path,
# so it's deterministic per-repo (or per-worktree) as long as the project
# doesn't move.

GIT_DIR=$(git rev-parse --git-dir 2>/dev/null) || {
    echo "Not in a git repository"
    sleep 1
    exit 1
}

# Make absolute if relative
case "$GIT_DIR" in
    /*) ;;
    *) GIT_DIR="$PWD/$GIT_DIR" ;;
esac

# Deterministic tempfile path based on git dir
HASH=$(printf '%s' "$GIT_DIR" | md5 -q)
TASK_FILE="${TMPDIR:-/tmp}/kitty-task-${HASH}"

# Open nvim to edit the 1-line task description
nvim "$TASK_FILE"

# Clear any manual tab title so tab_bar.py renders the project format
kitty @ set-tab-title ""
