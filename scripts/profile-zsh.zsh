#!/usr/bin/env zsh
# Profile individual zsh components

typeset -A times

time_source() {
  local name=$1
  local file=$2
  local start=$(date +%s%3N)
  source "$file" 2>/dev/null
  local end=$(date +%s%3N)
  times[$name]=$((end - start))
}

echo "=== Profiling ZSH Components ==="
echo ""

# Test p10k instant prompt
start=$(date +%s%3N)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
times[p10k-instant]=$(($(date +%s%3N) - start))

# Antidote setup
start=$(date +%s%3N)
source ${ZDOTDIR:-~}/.antidote/antidote.zsh
times[antidote-setup]=$(($(date +%s%3N) - start))

# Individual ohmyzsh libs
CACHE="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh"
time_source "omz-clipboard" "$CACHE/lib/clipboard.zsh"
time_source "omz-completion" "$CACHE/lib/completion.zsh"
time_source "omz-directories" "$CACHE/lib/directories.zsh"
time_source "omz-history" "$CACHE/lib/history.zsh"
time_source "omz-key-bindings" "$CACHE/lib/key-bindings.zsh"
time_source "omz-theme" "$CACHE/lib/theme-and-appearance.zsh"

# zsh-defer
DEFER="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-defer"
time_source "zsh-defer" "$DEFER/zsh-defer.plugin.zsh"

# autosuggestions
AUTO="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions"
time_source "autosuggestions" "$AUTO/zsh-autosuggestions.plugin.zsh"

# completions
COMP="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-completions"
time_source "zsh-completions" "$COMP/zsh-completions.plugin.zsh"

# powerlevel10k
P10K="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-powerlevel10k"
time_source "powerlevel10k" "$P10K/powerlevel10k.zsh-theme"

# evalcache
EVAL="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-mroth-SLASH-evalcache"
time_source "evalcache" "$EVAL/evalcache.plugin.zsh"

# fzf-tab
FZF="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-Aloxaf-SLASH-fzf-tab"
time_source "fzf-tab" "$FZF/fzf-tab.plugin.zsh"

# belak completion (runs compinit)
BELAK="$HOME/Library/Caches/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-belak-SLASH-zsh-utils/completion"
time_source "belak-compinit" "$BELAK/completion.plugin.zsh"

# Print results sorted by time
echo "Component                Time (ms)"
echo "--------------------------------"
for key in ${(k)times}; do
  printf "%-24s %4d\n" "$key" "${times[$key]}"
done | sort -t' ' -k2 -n -r

echo ""
echo "Total: $((${(v)times[@]:#})) ms (approx)"
