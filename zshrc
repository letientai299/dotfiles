# Put the dotfile location into path
if [[ "$OSTYPE" == "darwin"* ]]; then
  export DOTFILES="$(dirname $(realpath ~/.zshrc))"
else
  export DOTFILES="$(dirname $(readlink -f ~/.zshrc))"
fi

# Load zplug config
source "$DOTFILES/zplugconfig";

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


# Remove the duplicated entries in path
typeset -U PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# NVM setup is about the only thing in this script that takes any noticeable time to run.
# Which is not something you want in your .bashrc...
# So, we use a 'just in time' approach. Setup a function that loads the 'real' nvm on first
# use. Note that the 'nvm' function defined here gets over-ridden via sourcing nvm.sh:
# (So you get the ~600ms delay only on first use, in any shell)
export NVM_DIR="$HOME/.nvm"
function nvm() {
  echo "🚨 NVM not loaded! Loading now..."
  unset -f nvm
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
	nvm "$*"
}

# Load per machine setting
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# [[ -s "/home/john/.gvm/scripts/gvm" ]] && source "/home/john/.gvm/scripts/gvm"

# ZSH checking the cached .zcompdump to see if it needs regenerating. The
# simplest fix is to only do that once a day.
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

