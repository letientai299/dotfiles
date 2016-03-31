export ZSH=~/.oh-my-zsh
ZSH_THEME="xxf"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git gradle adb vi-mode)

# User configuration
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
source $ZSH/oh-my-zsh.sh
export LANG=en_US.UTF-8

# I still change my configuration a lot, so I wanna soften the typing.
alias so="source"

# Add, commit and push in single call
function lazygit() {
if [ $# -eq 0 ]; then # Check for commit message
    echo "Need a commit message"
    return 1
fi
git add .
git commit -a -m "$*"
git push
}

alias lg="lazygit" # And even more lazy

# This is a habit, and I want to make this habit work
function quit_session {
    if ! { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
        # Not in a tmux session, just do normal exit.
        exit
    else
        tmux detach
    fi
}
alias exit=quit_session
alias :q=quit_session

# Get current day
alias today="date +%Y-%m-%d"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# Inverse recursive search for a find name
# Usage:
#    findup <file_name>
findup () {
  file_name=$1
  current_dir=`pwd`
  local  result=1

  while [[ "`pwd`" != "/" ]]; do
    if [ -f ${file_name} ]; then
      echo `pwd`"/"${file_name}
      result=0
      break
    fi
    cd ..
  done

  if [ ${result} -eq 1 ]; then
    echo "Cannot found ${file_name}"
  fi

  cd ${current_dir}
  return ${result}
}


#Custom key binding
bindkey -s "^j" "|less^m"
bindkey -s "jk" "^["
bindkey "^u" "history-incremental-search-backward"
bindkey "^b" "history-incremental-search-forward"

# include local settings if file existing
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# finally remove the duplicated entries in path
typeset -U PATH
