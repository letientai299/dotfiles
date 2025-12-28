#!/bin/bash

local_todo() {
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ -z $git_common_dir ]]; then
    echo "not a git repo"
    return
  fi

  # Resolve to the main worktree (parent of .git directory)
  repo=$(cd "$git_common_dir" && cd .. && pwd)

  mkdir -p "$repo"/.dump
  vim "$repo"/.dump/todo.md
}
