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

task "Install Development tools"
sudo yum groupinstall -y "Development Tools"
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
sudo yum -y install neovim
sudo pip3 install neovim
sudo pip install neovim

task "Xclip and xsel (for neovim clipboard)"
sudo yum install xclip xsel -y

task "Ruby and neovim binding"
sudo yum install ruby-devel ruby -y
sudo gem install neovim

task "tmux"
curl https://gist.githubusercontent.com/letientai299/001999f745e05e8f3ea370956cbdacf7/raw/b9b65d2fed6238faad5264db5ca61ae2587e3293/centos7-tmux.sh | bash -

task "Ranger"
sudo yum install -y w3m w3m-img highlight
curl https://gist.githubusercontent.com/letientai299/001999f745e05e8f3ea370956cbdacf7/raw/eddd3aed749b313668b3e05f82b5ba624b36523a/centos7-ranger.sh | bash -

task 'Zathura'
sudo yum install -y zathura

task "rg search"
sudo yum install ripgrep -y
wget https://github.com/aykamko/tag/releases/download/v1.4.0/tag_linux_amd64.tar.gz
tar -zxf tag_linux_amd64.tar.gz
mv tag ~/.local/bin
rm tag_linux_amd64.tar.gz

cat << HERE >> $HOME/.zshrc_local
if (( $+commands[tag] )); then
  export TAG_SEARCH_PROG=rg  # replace with rg for ripgrep
  tag() { command tag "\$@"; source \${TAG_ALIAS_FILE:-/tmp/tag_aliases} 2>/dev/null }
  alias rg=tag  # replace with rg for ripgrep
fi
HERE


task "curl and wget"
sudo yum install -y curl wget

task "zsh"
sudo yum install -y zsh util-linux-user
sudo chsh  -s "$(which zsh)" $USER

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

task "Term 256 color"
wget "https://gist.github.com/sos4nt/3187620/raw/bca247b4f86da6be4f60a69b9b380a11de804d1e/xterm-256color-italic.terminfo"
tic xterm-256color-italic.terminfo
rm xterm-256color-italic.terminfo
