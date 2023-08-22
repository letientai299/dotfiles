#!/bin/bash

file=$1
line=$2
col=$3


NVIM_SOCKET=/tmp/neovide.socket
if [ ! -S $NVIM_SOCKET ]; then
  neovide $file -- --listen $NVIM_SOCKET -c "+cal cursor($line,$col)"
else
  nvim --server $NVIM_SOCKET --remote $file
  nvim --server $NVIM_SOCKET --remote-send "$line"G"$col"lh
  osascript <<END
  tell application "Neovide"
    activate
  end tell
END
fi
