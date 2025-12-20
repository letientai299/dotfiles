#!/bin/sh
# Fast custom segment: my_todo - shows current task from .dump/todo.md
# Uses STARSHIP_GIT_ROOT env var (cached by zsh precmd) to avoid git calls

# Use cached git root from env var, fallback to git command
root="${STARSHIP_GIT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -z "$root" ] && root="."
todo_file="$root/.dump/todo.md"

[ ! -f "$todo_file" ] && exit 0

# Get first task line and remove leading "- "
task=$(head -n1 "$todo_file" 2>/dev/null)
task="${task#- }"

[ -z "$task" ] && exit 0

# Truncate if too long (POSIX)
if [ ${#task} -gt 30 ]; then
  task="$(printf '%.27s' "$task")..."
fi

printf '%s' "$task"
