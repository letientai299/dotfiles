#!/bin/sh
# Fast custom segment: my_todo - shows current task from .dump/todo.md
# Colors: fix/bug=orange(208), feat=green(46), doc=cyan(51), default=blue(33)

# Find git root or use current dir
root=$(git rev-parse --show-toplevel 2>/dev/null) || root="."
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

echo $task
