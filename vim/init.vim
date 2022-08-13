set rtp+=~/.vim,~/.vim/after
source ~/.vim/vimrc
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" fix Ctrl-I navigate in jump list
" https://github.com/neovim/neovim/issues/17867
if $TERM ==# 'xterm-kitty'
  autocmd UIEnter * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[>1u") | endif
  autocmd UILeave * if v:event.chan ==# 0 | call chansend(v:stderr, "\x1b[<1u") | endif
endif

