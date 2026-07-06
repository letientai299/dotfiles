#!/bin/bash

sudo true -v

task() {
  echo
  echo
  echo "========================================"
  echo "$*"
  echo "========================================"
}

task "Make sure everything is up-to-date"
brew update

task "Git"
brew install git

task "Neovim"
brew install neovim

task "Python and neovim binding"
brew install python3
pip3 install --upgrade pip
pip3 install --user neovim
echo 'export PATH=$PATH:$HOME/.local/bin' >>$HOME/.profile

task "Tmux"
brew install tmux

task "rg search"
brew install ripgrep
wget https://github.com/aykamko/tag/releases/download/v1.4.0/tag_darwin_amd64.zip
tar -zxf tag_darwin_amd64.zip
mkdir -p ~/.local/bin
mv tag ~/.local/bin
rm tag_darwin_amd64.zip

cat <<HERE >>$HOME/.zshrc_local
if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=rg  # replace with rg for ripgrep
  tag() { command tag "\$@"; source "\${TAG_ALIAS_FILE:-/tmp/tag_aliases}" 2>/dev/null }
  alias rg=tag  # replace with rg for ripgrep
fi
HERE

task "curl and wget"
brew install curl wget

task "Term 256 color"
wget "https://gist.github.com/sos4nt/3187620/raw/bca247b4f86da6be4f60a69b9b380a11de804d1e/xterm-256color-italic.terminfo"
tic xterm-256color-italic.terminfo
rm xterm-256color-italic.terminfo

