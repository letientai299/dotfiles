#!/bin/bash
POS=$(cmus-remote -Q | grep "position " | cut -c 10-)
date -u +%m:%S -d @"$POS"
