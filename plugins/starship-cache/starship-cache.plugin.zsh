# starship-cache.plugin.zsh
# Caches git info for starship custom modules to avoid repeated git calls.
# The precmd hook runs once per prompt, then custom scripts read from env vars.

_starship_precmd_git_cache() {
  unset STARSHIP_GIT_ROOT STARSHIP_GIT_COMMIT_MSG
  local git_root
  git_root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  export STARSHIP_GIT_ROOT="$git_root"
  export STARSHIP_GIT_COMMIT_MSG=$(git log -1 --pretty=format:'%s' 2>/dev/null)
}

# Register the precmd hook
precmd_functions=(_starship_precmd_git_cache $precmd_functions)
