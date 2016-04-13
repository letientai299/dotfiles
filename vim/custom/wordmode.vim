"------------------------------------------------------------------------------
" The following script is copied from (with modification to use with my setup)
" https://davidxmoody.com/vim-auto-capitalisation/
" This make vim capitalize the first letter of the sentence.
func! WordProcessorMode()
    " Auto-capitalize script
    augroup SENTENCES
        au!
        autocmd InsertCharPre * if search('\v(%^|[.!?]\_s+|\_^\-\s|\_^title\:\s|\n\n)%#', 'bcnw') != 0 | let v:char = toupper(v:char) | endif
    augroup END

    " ---------------------
    " some custom setting
    " Quickly format the paregraph, and also a way to avoid enter Ex-mode
    nnoremap gQ gqap

endfu

com! WordProcessorMode call WordProcessorMode()
