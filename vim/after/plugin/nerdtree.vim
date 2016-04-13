" This script have come custom for the NERDTree plugin
"------------------------------------------------------

" Shortcut to quickly open the NerdTree panel
nnoremap <c-f12> :NERDTreeToggle<CR>
" Quickly reveal the location of opened buffer.
nnoremap <c-s-f12> :NERDTreeFind<CR>

" Command to highlight by file extension
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
    exec 'autocmd FileType nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
    exec 'autocmd FileType nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

au VimEnter * call NERDTreeHighlightFile('jade', 'green', 'none', 'green', 'white')
au VimEnter * call NERDTreeHighlightFile('ini', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('py', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('md', '19', 'none', '#3366FF', 'white')
au VimEnter * call NERDTreeHighlightFile('yml', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('config', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('conf', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('json', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('html', '100', 'none', 'Yellow4', 'white')
au VimEnter * call NERDTreeHighlightFile('styl', '19', 'none', 'cyan', 'white')
au VimEnter * call NERDTreeHighlightFile('css', '19', 'none', 'cyan', 'white')
au VimEnter * call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', 'white')
au VimEnter * call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', 'white')
au VimEnter * call NERDTreeHighlightFile('rb', 'Red', 'none', '#ffa500', 'white')
au VimEnter * call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', 'white')

