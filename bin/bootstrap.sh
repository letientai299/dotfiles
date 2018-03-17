#!/bin/sh

# check for readlink/realpath presence
# https://github.com/deadc0de6/dotdrop/issues/6
rl="readlink -f"

if ! ${rl} "${0}" >/dev/null 2>&1; then
  rl="realpath"

  if ! hash ${rl}; then
    echo "\"${rl}\" not found !" && exit 1
  fi
fi

export WORKING_DIR=$(dirname "$(${rl} "$0")")

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

if command -v brew > /dev/null 2>&1; then
  echo "Has brew. Use macOS script."
  $WORKING_DIR/bootstrap-macos.sh
  exit;
fi


echo "Unsupported Operating System. If this is a Mac, please install homebrew."
exit 1;

