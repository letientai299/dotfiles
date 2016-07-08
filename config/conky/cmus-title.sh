#!/bin/bash
local song_title
song_title=$(cmus-remote -Q | grep " title " | cut -c 11-)
echo "$song_title"
