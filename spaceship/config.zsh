SPACESHIP_PROMPT_ORDER=(
  aws
  time        # Time stamps section
  dir         # Current directory section
  git         # Git section (git_branch + git_status)
  git_last_commit
  exec_time   # Execution time
  line_sep    # Line break
  jobs        # Background jobs indicator
  exit_code   # Exit code section
  char        # Prompt character
)
