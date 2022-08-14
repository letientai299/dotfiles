augroup vimrc_todo
    au!
    au Syntax * syn match CustomTodo /\v<(FIXME|NOTE|TODO|OPTIMIZE|XXX|TBD|WTF|WARN)/
          \ containedin=.*Comment,vimCommentTitle,.*Doc
augroup END
hi def link CustomTodo Todo
