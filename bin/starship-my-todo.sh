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

# Color based on task type (case-insensitive patterns)
case "$task" in
  [Ff][Ii][Xx]*|[Bb][Uu][Gg]*)
    printf '\033[38;5;208m%s\033[0m' "$task"  # orange
    ;;
  [Ff][Ee][Aa][Tt]*)
    printf '\033[38;5;46m%s\033[0m' "$task"   # green
    ;;
  [Dd][Oo][Cc]*)
    printf '\033[38;5;51m%s\033[0m' "$task"   # cyan
    ;;
  *)
    printf '\033[38;5;33m%s\033[0m' "$task"   # blue
    ;;
esac
