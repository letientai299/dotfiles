TERM=xterm-256color
#------------------------------------------------------------------------------
# Zplug
#------------------------------------------------------------------------------
# Install zplug if it is not installed
if [ ! -f ~/.zplug/zplug ]; then
  echo "Zplug not found, installing to home..."
  git clone https://github.com/b4b4r07/zplug ~/.zplug
  echo "Done."
fi

# Load zplug config
source ~/.zplugconfig;

#------------------------------------------------------------------------------
# Other config
#------------------------------------------------------------------------------
# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
for file in ~/.{path,exports,aliases,funcs,bindkeys}; do
    if [ -r "$file" ] && [ -f "$file" ]; then
        source "$file";
    fi
done;
unset file;

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


#------------------------------------------------------------------------------
# Per machine setting
#------------------------------------------------------------------------------
if [ -f ~/.zshrc_local ]; then
    source ~/.zshrc_local
fi


#------------------------------------------------------------------------------
# Finallize
#------------------------------------------------------------------------------
# Remove the duplicated entries in path
typeset -U PATH

