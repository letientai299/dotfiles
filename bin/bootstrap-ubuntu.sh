#!/bin/sh

task() {
  echo
  echo
  echo "========================================"
  echo "$*"
  echo "========================================"
}

task "Make sure everything is up-to-date"
sudo apt update && sudo apt dist-upgrade -y && sudo apt full-upgrade -y

task "Build essential"
sudo apt install -y build-essential software-properties-common

task "Git PPA for latest release"
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt update
sudo apt install git -y

task "Grub Customizer"
sudo add-apt-repository ppa:danielrichter2007/grub-customizer -y
sudo apt update
sudo apt install grub-customizer -y

task "Numix color theme"
sudo add-apt-repository ppa:numix/ppa -y
sudo apt update
sudo apt install -y numix-gtk-theme numix-icon-theme-circle
sudo apt install -y gnome-tweak-tool

task "Neovim"
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install neovim -y

task "Xclip and xsel (for neovim clipboard)"
sudo apt install xclip xsel -y

task "Python and neovim binding"
sudo apt install python python3 python-dev python3-dev python-pip python3-pip -y
pip install --upgrade pip
pip install --user neovim
pip3 install --upgrade pip
pip3 install --user neovim
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.profile

task "Ruby and neovim binding"
sudo apt install ruby-dev ruby -y
sudo gem install neovim

task "Tmux"
sudo apt install tmux -y

task "Ranger"
sudo apt install -y ranger w3m w3m-img highlight
ranger --copy-config=all

task 'Zathura'
sudo apt install -y zathura

task "ag search"
sudo apt install silversearcher-ag -y
wget https://github.com/aykamko/tag/releases/download/v1.4.0/tag_linux_amd64.tar.gz
tag -zxf tag_linux_amd64.tar.gz
mv tag ~/.local/bin
rm tag_linux_amd64.tar.gz

cat << HERE >> $HOME/.zshrc_local
if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=ag  # replace with rg for ripgrep
  tag() { command tag "$@"; source ${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias ag=tag  # replace with rg for ripgrep
fi
HERE

task "curl and wget"
sudo apt install -y curl wget

task "zsh"
sudo apt install -y zsh
chsh  -s "$(which zsh)"

task "Nodejs"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs

task "Fix NPM permissions"
mkdir ~/.npm-global
npm config set prefix "$HOME/.npm-global"
echo '# Fix npm permissions' >> $HOME/.profile
echo 'export PATH=$PATH:$HOME/.npm-global/bin' >> $HOME/.profile

task "Nodemon"
npm install -g nodemon

task "Diff-so-fancy"
npm install -g diff-so-fancy
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global color.ui true
git config --global color.diff-highlight.oldNormal "red bold"
git config --global color.diff-highlight.oldHighlight "red bold 52"
git config --global color.diff-highlight.newNormal "green bold"
git config --global color.diff-highlight.newHighlight "green bold 22"
git config --global color.diff.meta "227"
git config --global color.diff.frag "magenta bold"
git config --global color.diff.commit "227 bold"
git config --global color.diff.old "red bold"
git config --global color.diff.new "green bold"
git config --global color.diff.whitespace "red reverse"

task "Update path to load nodejs binaries"
echo 'export PATH="$PATH:$HOME/.npm-global/bin"' >> ~/.profile

task "sdkman"
curl -s "https://get.sdkman.io" | bash

task "Term 256 color"
wget "https://gist.github.com/sos4nt/3187620/raw/bca247b4f86da6be4f60a69b9b380a11de804d1e/xterm-256color-italic.terminfo"
tic xterm-256color-italic.terminfo
rm xterm-256color-italic.terminfo

