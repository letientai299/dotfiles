#!/bin/bash
ALL=$(cmus-remote -Q | grep "duration " | cut -c 10-)
POS=$(cmus-remote -Q | grep "position " | cut -c 10-)
echo "$POS" '*' 100 / "$ALL" | bc
