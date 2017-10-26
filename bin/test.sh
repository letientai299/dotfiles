#!/bin/sh

cat << HERE >> $HOME/.zshrc_local
if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=ag  # replace with rg for ripgrep
  tag() { command tag "\$@"; source "\${TAG_ALIAS_FILE:-/tmp/tag_aliases}" 2>/dev/null }
  alias ag=tag  # replace with rg for ripgrep
fi
HERE

