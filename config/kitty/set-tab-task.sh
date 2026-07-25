#!/bin/bash
# Edit the current kitty tab's task description.
#
# The task is stored in a tempfile keyed by kitty's stable tab id (not index, so
# reordering tabs is fine). This binds the task to the tab — not to a git repo —
# so the label stays consistent no matter which pane you switch to, and works in
# non-git dirs. tab_bar.py reads this file to render the tab title, and prunes it
# once the tab no longer exists.

# Talk to the kitty instance we're running inside. kitty appends its PID to
# `listen_on`, so the real socket path lives in $KITTY_LISTEN_ON (inherited by
# this overlay) — don't hardcode the configured path.
ls_json=$(kitty @ ls 2>/dev/null)

# Resolve this tab's id by matching the overlay's window ($KITTY_WINDOW_ID).
tab_id=$(printf '%s' "$ls_json" | jq -r --arg w "$KITTY_WINDOW_ID" '
  .[].tabs[] | select(any(.windows[]?; (.id | tostring) == $w)) | .id' | head -1)

# Fall back to the focused tab if the window match fails.
if [ -z "$tab_id" ]; then
  tab_id=$(printf '%s' "$ls_json" |
    jq -r '.[].tabs[] | select(.is_focused) | .id' | head -1)
fi

if [ -z "$tab_id" ]; then
  echo "Could not determine kitty tab id"
  sleep 1
  exit 1
fi

task_file="${TMPDIR:-/tmp}/kitty-task-tab-${tab_id}"

# Open nvim to edit the 1-line task description.
/usr/local/bin/nvim "$task_file"
