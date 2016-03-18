export ZSH=~/.oh-my-zsh
ZSH_THEME="xxf"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

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
alias :q=quit_session

# Get current day
alias today="date +%Y-%m-%d"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# include local settings if file existing
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# finally remove the duplicated entries in path
typeset -U PATH
