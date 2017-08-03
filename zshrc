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

# Remove the duplicated entries in path
typeset -U PATH
#  }}} Finalize  #

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#  Finalize {{{ #
# Load per machine setting
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi


# tabtab source for electron-forge package
# uninstall by removing these lines or running `tabtab uninstall electron-forge`
[[ -f /home/john/.config/yarn/global/node_modules/tabtab/.completions/electron-forge.zsh ]] && . /home/john/.config/yarn/global/node_modules/tabtab/.completions/electron-forge.zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
