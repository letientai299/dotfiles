# Put the dotfile location into path
if [[ "$OSTYPE" == "darwin"* ]]; then
  export DOTFILES="$(dirname $(realpath ~/.zshrc))"
else
  export DOTFILES="$(dirname $(readlink -f ~/.zshrc))"
fi

# zmodload zsh/zprof

# Load zgen config
source "$DOTFILES/zgenconfig";

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

source $DOTFILES/spaceship/last-commit.zsh
source $DOTFILES/spaceship/config.zsh

# Remove the duplicated entries in path
typeset -U PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
