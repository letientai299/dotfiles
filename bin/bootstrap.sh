#!/bin/sh
export WORKING_DIR=$(dirname "$(readlink -f "$0")")

if command -v apt-get > /dev/null 2>&1; then
  echo "Has apt-get. Use debian script"
  $WORKING_DIR/bootstrap-ubuntu.sh
  exit;
fi

if command -v yum > /dev/null 2>&1; then
  echo "Has yum. Use centos script."
  $WORKING_DIR/bootstrap-centos.sh
  exit;
fi

echo "Unsupported Operating System"
exit 1;

