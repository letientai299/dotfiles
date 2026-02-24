#!/bin/bash
# Edit kitty tab task description for the current git project.
# The task file is stored in the git dir so it's per-repo (or per-worktree).

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

TASK_FILE="$GIT_DIR/kitty-task"

# Open nvim to edit the 1-line task description
nvim "$TASK_FILE"

# Clear any manual tab title so tab_bar.py renders the project format
kitty @ set-tab-title ""
