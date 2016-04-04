" Open the today note.
function! OpenTodayNote()
    let todayString = strftime("%Y-%m-%d")
    let journalFolder= $NOTE."/journal/"
    let todayFilePath = journalFolder.todayString.".md"
    execute "tabedit".' '.todayFilePath
endfunction

nmap <Leader>ww :call OpenTodayNote()<CR>
