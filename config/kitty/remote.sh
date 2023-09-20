#!/usr/bin/env bash

SOCKET=unix:/tmp/kitty-remote-$RANDOM
echo $SOCKET
kitty -o allow_remote_control=yes --listen-on $SOCKET -o enabled_layouts=grid &
sleep 0.5

kitty @ --to $SOCKET kitten broadcast
kitty @ --to $SOCKET new-window
kitty @ --to $SOCKET new-window
kitty @ --to $SOCKET new-window
kitty @ --to $SOCKET new-window
kitty @ --to $SOCKET focus-window --match id:1
