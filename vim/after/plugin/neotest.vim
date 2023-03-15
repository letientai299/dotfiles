command! TestNearest lua require("neotest").run.run()
" shift-f10
map <F22> :TestNearest<cr>

command! TestSummary lua require("neotest").summary.toggle()
" ctrl-f10
map <F34> :TestSummary<cr>
