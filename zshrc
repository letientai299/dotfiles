export ZSH=~/.oh-my-zsh
ZSH_THEME="xxf"
HYPHEN_INSENSITIVE="true"
ENABLE_CORRECTION="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh_reload git gradle adb vi-mode pip colored-man-pages)

# User configuration
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
source $ZSH/oh-my-zsh.sh

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
for file in ~/.{path,exports,aliases,funcs,bindkeys}; do
    if [ -r "$file" ] && [ -f "$file" ]; then
        source "$file";
    fi
done;
unset file;


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# include local settings if file existing
# This should always be the last call to source. Because the local
# machine setting may need to override something.
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi

# finally remove the duplicated entries in path
typeset -U PATH

