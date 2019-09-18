#!/bin/bash

# Every 30 minutes cron job
# */30 * * * *

WORKING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$WORKING_DIR/.." || exit

git pull
git add .
now=$(date '+%F %a %T')
git commit -m "Sync note $now"
git push
