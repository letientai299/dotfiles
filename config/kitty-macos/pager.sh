#!/usr/bin/env bash

# modified from https://github.com/kovidgoyal/kitty/issues/719#issuecomment-952039731

if [ "$#" -eq 3 ]; then
  INPUT_LINE_NUMBER=${1:-0}
  CURSOR_LINE=${2:-1}
  CURSOR_COLUMN=${3:-1}
  AUTOCMD_TERMCLOSE_CMD="call cursor(max([0,${INPUT_LINE_NUMBER}-1])+${CURSOR_LINE}, ${CURSOR_COLUMN})"
else
  AUTOCMD_TERMCLOSE_CMD="normal G"
fi

# /usr/local/bin/nvim \
#   -c "set laststatus=0" \
#   -c "set colorcolumn=0" \
#   -c "set tw=10000 nowrap" \
#   -c "silent CocDisable" \
#   -c "map <silent> q :qa!<CR>" \
#   -c "let baleia = luaeval(\"require('baleia').setup { }\")" \
#   -c "call baleia.once(bufnr('%'))" \
#   -c "BufferLineGroupToggle ungrouped"

/usr/local/bin/nvim 63<&0 0</dev/null \
  -c "set nonumber" \
  -c "set laststatus=0" \
  -c "set colorcolumn=0" \
  -c "set tw=10000" \
  -c "silent CocDisable" \
  -c "autocmd TermEnter * stopinsert" \
  -c "autocmd TermClose * ${AUTOCMD_TERMCLOSE_CMD}" \
  -c "map <silent> q :qa!<CR>" \
  -c 'terminal sed </dev/fd/63 && sleep 0.01 && printf "\x1b]2;"' \
  -c "BufferLineGroupToggle ungrouped"

