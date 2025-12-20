# starship-cache.plugin.zsh
# Caches git info for starship custom modules to avoid repeated git calls.
# The precmd hook computes everything once, starship reads from env vars.

_starship_precmd_git_cache() {
  # Clear all cached values
  unset STARSHIP_GIT_ROOT STARSHIP_GIT_COMMIT_MSG STARSHIP_GIT_ROOT_DISPLAY STARSHIP_TODO

  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  export STARSHIP_GIT_ROOT="$git_root"

  # Cache commit message with WIP highlighting
  local msg=$(git log -1 --pretty=format:'%s' 2>/dev/null)
  if [[ -n "$msg" ]]; then
    if [[ "$msg" =~ ^[Ww][Ii][Pp] ]]; then
      # WIP commit - format with orange color
      local rest="${msg#[Ww][Ii][Pp]}"
      rest="${rest# }" && rest="${rest#:}" && rest="${rest# }" && rest="${rest#-}" && rest="${rest# }"
      if [[ -n "$rest" ]]; then
        # Truncate if needed (70 - 4 for "WIP ")
        (( ${#rest} > 66 )) && rest="${rest:0:63}..."
        export STARSHIP_GIT_COMMIT_MSG=$'\e[1;38;5;208mWIP\e[0m '"$rest"
      else
        export STARSHIP_GIT_COMMIT_MSG=$'\e[1;38;5;208mWIP\e[0m'
      fi
    else
      # Regular commit - truncate if needed
      (( ${#msg} > 70 )) && msg="${msg:0:67}..."
      export STARSHIP_GIT_COMMIT_MSG="$msg"
    fi
  fi

  # Cache git root display (only show if depth >= 3)
  local cwd="$PWD"
  local relative="${cwd#$git_root}"
  if [[ "$relative" != "$cwd" ]]; then
    local depth="${relative//[^\/]/}"
    if (( ${#depth} >= 3 )); then
      export STARSHIP_GIT_ROOT_DISPLAY="[${git_root##*/}]"
    fi
  fi

  # Cache todo (check if file exists)
  local todo_file="$git_root/.dump/todo.md"
  if [[ -f "$todo_file" ]]; then
    local task
    read -r task < "$todo_file"
    task="${task#- }"
    if [[ -n "$task" ]]; then
      (( ${#task} > 30 )) && task="${task:0:27}..."
      export STARSHIP_TODO="$task"
    fi
  fi
}

# Register the precmd hook using add-zsh-hook for proper ordering
autoload -Uz add-zsh-hook
add-zsh-hook precmd _starship_precmd_git_cache
