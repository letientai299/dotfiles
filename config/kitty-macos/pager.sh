#!/usr/bin/env bash
set -eu

ID=$KITTY_WINDOW_ID

# nvim -c "silent write! /tmp/kitty_$ID | te /bin/cat /tmp/kitty_$ID - "

nvim $* \
    -c "map <silent> q :qa!<CR>" \
    -c "silent write ! /tmp/kitty_$ID" \
    -c "terminal /bin/cat /tmp/kitty_$ID"
