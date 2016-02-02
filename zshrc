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

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.

alias s2040='ssh eng2@hcutwrk2040'
alias ff="firefox"
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
alias :q="exit"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
