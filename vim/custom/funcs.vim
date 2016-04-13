" I don't use this anymore, actually move to vimwiki.
" But I still keep this code as an example about custom function in vim.
" Maybe it helpful in the future.
" Open the today note.
"function! OpenTodayNote()
    "let todayString = strftime("%Y-%m-%d")
    "let journalFolder= $NOTE."/journal/"
    "let todayFilePath = journalFolder.todayString.".md"
    "execute "tabedit".' '.todayFilePath
"endfunction

"nmap <Leader>ww :call OpenTodayNote()<CR>

nmap <leader>gf :e <cfile><cr>
