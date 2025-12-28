#!/bin/bash

local_todo() {
  repo=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -z $repo ]]; then
    echo "not a git repo"
    return
  fi

  mkdir -p "$repo"/.dump
  vim "$repo"/.dump/todo.md
}
