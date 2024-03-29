#!/bin/bash

file=$1
line=${2:-0}
col=${3:-0}

NVIM_SOCKET=/tmp/neovide.socket
if [ ! -S $NVIM_SOCKET ]; then
  if [ -z $file ]; then
    neovide -- --listen $NVIM_SOCKET
  else
    neovide $file -- --listen $NVIM_SOCKET -c "+cal cursor($line,$col)"
  fi
else
  nvim --server $NVIM_SOCKET --remote $file
  nvim --server $NVIM_SOCKET --remote-send "$line"G"$col"lh
  osascript <<END
  tell application "Neovide"
    activate
  end tell
END
fi
