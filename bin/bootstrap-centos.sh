#!/bin/sh

task() {
  echo
  echo
  echo "========================================"
  echo "$*"
  echo "========================================"
}

task "Make sure everything is up-to-date"
sudo yum upgrade -y

task "Install softwares"
sudo yum install -y git python python-devel python3 python3-devel python-pip python3-pip gcc-c++ make which
echo 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.profile

task "Neovim"
sudo yum -y install neovim python2-neovim python3-neovim

task "Xclip and xsel (for neovim clipboard)"
sudo yum install xclip xsel -y

task "Ruby and neovim binding"
sudo yum install ruby-devel ruby -y
sudo gem install neovim

task "Tmux"
sudo yum install tmux -y

task "Ranger"
sudo yum install -y ranger w3m w3m-img highlight
ranger --copy-config=all

task 'Zathura'
sudo yum install -y zathura

task "ag search"
sudo yum install the_silver_searcher -y

task "curl and wget"
sudo yum install -y curl wget

task "zsh"
sudo yum install -y zsh util-linux-user
sudo chsh  -s "$(which zsh)" $USER

task "Nodejs"
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
sudo yum install -y nodejs

task "Fix NPM permissions"
mkdir ~/.npm-global
npm config set prefix "$HOME/.npm-global"
echo '# Fix npm permissions' >> $HOME/.profile
echo 'export PATH=$PATH:$HOME/.npm-global/bin' >> $HOME/.profile

task "Nodemon"
npm install -g nodemon

task "Diff-so-fancy"
npm install -g nodemon
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
