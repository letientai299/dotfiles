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

task "Python"
sudo yum -y install yum-utils
sudo yum -y groupinstall development
sudo yum -y install https://centos7.iuscommunity.org/ius-release.rpm
sudo yum -y install python36u
sudo yum -y install python36u-pip
sudo yum -y install python36u-devel
sudo ln -s /usr/bin/python3.6 /usr/bin/python3
sudo ln -s /usr/bin/pip3.6 /usr/bin/pip3

task "Neovim"
sudo yum -y install epel-release
sudo curl -o /etc/yum.repos.d/dperson-neovim-epel-7.repo https://copr.fedorainfracloud.org/coprs/dperson/neovim/repo/epel-7/dperson-neovim-epel-7.repo
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
