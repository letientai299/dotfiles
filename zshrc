TERM=xterm-256color
export DOTFILES="$(dirname $(readlink -f ~/.zshrc))"
#------------------------------------------------------------------------------
# Zplug
#------------------------------------------------------------------------------
# Install zplug if it is not installed
if [ ! -f ~/.zplug/zplug ]; then
  echo "Zplug not found, installing to home..."
  git clone https://github.com/b4b4r07/zplug ~/.zplug
  # There's a problem with v2 that make theme not load correctly
  cd ~/.zplug/
  git checkout v1
  cd ~
  echo "Done."
fi

# Load zplug config
source "$DOTFILES"/zplugconfig;

#------------------------------------------------------------------------------
# ZSH setting
#------------------------------------------------------------------------------
# Disable <C-D> logout
setopt ignore_eof
# Disable beeps
setopt no_beep
# Ignore dups
setopt hist_ignore_dups


#------------------------------------------------------------------------------
# My zsh config
#------------------------------------------------------------------------------
# Make sure that nvim is installed
if ! hash nvim 2>/dev/null; then
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get update
  sudo apt-get install -y neovim
fi

# Make sure that fzf is installed.
if [ ! -f ~/.fzf.zsh ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi
source ~/.fzf.zsh

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
for file in "$DOTFILES"/{path,exports,aliases,funcs,bindkeys}; do
    if [ -r "$file" ] && [ -f "$file" ]; then
        source "$file";
    fi
done;
unset file;



#------------------------------------------------------------------------------
# Per machine setting
#------------------------------------------------------------------------------
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi


#------------------------------------------------------------------------------
# Finallize
#------------------------------------------------------------------------------
# Remove the duplicated entries in path
typeset -U PATH

