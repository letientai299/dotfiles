# vim: foldmethod=marker foldenable

# Put the dotfile location into path
export DOTFILES="$(dirname $(readlink -f ~/.zshrc))"

#  Install and load Zplug {{{ #

# Install if not installed
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

# }}} #

#  zsh config {{{ #

# Disable <C-D> logout
setopt ignore_eof
# Disable beeps
setopt no_beep
# Ignore dups
setopt hist_ignore_dups
# enable edit-command-line
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line


# Load custom shell script
for file in "$DOTFILES"/{path,exports,aliases,funcs,bindkeys}; do
    if [ -r "$file" ] && [ -f "$file" ]; then
        source "$file";
    fi
done;
unset file;

#  }}} zsh config #

#  Install favorite software {{{ #

# nvim
if ! hash nvim 2>/dev/null; then
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get update
  sudo apt-get install -y neovim
fi


# fzf .
if [ ! -f ~/.fzf.zsh ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
fi
source ~/.fzf.zsh

#  }}} Install favorite software #

#  Finalize {{{ #
# Load per machine setting
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# Remove the duplicated entries in path
typeset -U PATH
#  }}} Finalize  #

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/letientai299/.sdkman"
[[ -s "/home/letientai299/.sdkman/bin/sdkman-init.sh" ]] && source "/home/letientai299/.sdkman/bin/sdkman-init.sh"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
