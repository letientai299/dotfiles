#!/usr/bin/env zsh
# based on https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731

source ~/.zprofile


if [ "$#" -eq 3 ]; then
  INPUT_LINE_NUMBER=${1:-0}
  CURSOR_LINE=${2:-1}
  CURSOR_COLUMN=${3:-1}
  AUTOCMD_TERMCLOSE_CMD="call cursor(max([0,${INPUT_LINE_NUMBER}-1])+${CURSOR_LINE}, ${CURSOR_COLUMN})"
else
  AUTOCMD_TERMCLOSE_CMD="normal G"
fi

BUF_NAME="/tmp/kitty_$RANDOM"
/bin/cat >> "$BUF_NAME"


/usr/local/bin/nvim \
  -c "set nonumber laststatus=0 colorcolumn=0 tw=10000" \
  -c "set tw=10000" \
  -c "autocmd TermEnter * stopinsert" \
  -c "autocmd TermClose * ${AUTOCMD_TERMCLOSE_CMD}" \
  -c "map <silent> q :qa!<CR>" \
  -c "terminal /bin/cat $BUF_NAME && sleep 0.001 && printf '\x1b]2;'" \
  -c "BufferLineGroupToggle ungrouped"

rm $BUF_NAME
