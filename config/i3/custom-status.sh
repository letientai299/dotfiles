#!/bin/bash

i3status | while :
do
  read line
  status=$(cmus-remote -Q | grep "status " | cut -c 8-)

  # cmus not playing or not running
  if [[ "$status" != "playing" && "$status" != "paused" ]]; then
    echo "$line" || exit 1
  else
    local icon
    if [ "$status" == "playing" ];then
      icon="▶"
    else
      icon="⏸ "
    fi
    song_title=$(~/.config/conky/cmus-title.sh)
    all=$(~/.config/conky/cmus-all.sh)
    pos=$(~/.config/conky/cmus-pos.sh)
    echo "$icon $song_title ($pos / $all) | $line" || exit 1
  fi
done
