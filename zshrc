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

# zmodload zsh/zprof

# Load zgen config
# source "$DOTFILES/zgenconfig";

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


[[ -s "/Users/tai.le/.gvm/scripts/gvm" ]] && source "/Users/tai.le/.gvm/scripts/gvm"

export PATH="$HOME/.cargo/bin:$PATH"


# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit;
else
  compinit -C;
fi;

# zprof

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}Ã¢ÂÂÃ¢ÂÂÃ¢ÂÂ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})Ã¢ÂÂ¦%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}Ã¢ÂÂÃ¢ÂÂÃ¢ÂÂ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}Ã¢ÂÂÃ¢ÂÂÃ¢ÂÂ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

source "$DOTFILES/zinit_config";

# Load custom shell script
for file in "$DOTFILES"/{path,exports,aliases,funcs,bindkeys}; do
  if [ -r "$file" ] && [ -f "$file" ]; then
    source "$file";
  fi
done;
unset file;


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# To customize prompt, run `p10k configure` or edit ~/Projects/mine/dotfiles/p10k.zsh.
[[ ! -f ~/Projects/mine/dotfiles/p10k.zsh ]] || source ~/Projects/mine/dotfiles/p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="/Users/tai.le/.sdkman"
# [[ -s "/Users/tai.le/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/tai.le/.sdkman/bin/sdkman-init.sh"


