# zmodload zsh/zprof

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Put the dotfile location into path
if [[ "$OSTYPE" == "darwin"* ]]; then
  export DOTFILES="$(dirname $(realpath ~/.zshrc))"
else
  export DOTFILES="$(dirname $(readlink -f ~/.zshrc))"
fi


source ${ZDOTDIR:-~}/.antidote/antidote.zsh
zsh_plugins=${DOTFILES}/plugins.zsh
# Ensure you have a .zsh_plugins.txt file where you can add plugins.
[[ -f ${zsh_plugins:r}.txt ]] || touch ${zsh_plugins:r}.txt

# Lazy-load antidote.
fpath+=(${ZDOTDIR:-~}/.antidote)
autoload -Uz $fpath[-1]/antidote

# Generate static file in a subshell when .zsh_plugins.txt is updated.
if [[ ! $zsh_plugins -nt ${zsh_plugins:r}.txt ]]; then
  (antidote bundle <${zsh_plugins:r}.txt >|$zsh_plugins)
fi
source $zsh_plugins

# Disable <C-D> logout
setopt ignore_eof

# Disable beeps
setopt no_beep

# Ignore dups
setopt hist_ignore_dups


# Remove the duplicated entries in path
typeset -U PATH

# Load per machine setting
if [ -f ~/.zshrc_local ]; then
  source ~/.zshrc_local
fi

export PATH="$HOME/.cargo/bin:$PATH"

# zprof

# Load custom shell script
for file in "$DOTFILES"/{path,exports,aliases,funcs,bindkeys}; do
  if [ -r "$file" ] && [ -f "$file" ]; then
    source "$file";
  fi
done;
unset file;

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

