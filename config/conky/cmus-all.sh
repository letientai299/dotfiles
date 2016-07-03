#!/bin/bash
NUM=$(cmus-remote -Q | grep "duration " | cut -c 10-)
date -u +%M:%S -d @"$NUM"
