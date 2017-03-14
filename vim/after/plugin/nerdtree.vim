" This script have come custom for the NERDTree plugin
"------------------------------------------------------

nnoremap <C-F12> :NERDTreeToggle<CR>
nnoremap <F36> :NERDTreeToggle<CR>
nnoremap <S-F12> :NERDTreeFind<CR>
nnoremap <F24> :NERDTreeFind<CR>

" Command to highlight by file extension
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
    exec 'autocmd FileType nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
    exec 'autocmd FileType nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

au VimEnter * call NERDTreeHighlightFile('jade',   'green',   'none', 'green',   'none')
au VimEnter * call NERDTreeHighlightFile('ini',    '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('py',     '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('md',     'blue',      'none', '#3366FF', 'none')
au VimEnter * call NERDTreeHighlightFile('yml',    '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('config', '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('conf',   '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('json',   '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('html',   '100',     'none', 'Yellow4', 'none')
au VimEnter * call NERDTreeHighlightFile('styl',   '19',      'none', 'cyan',    'none')
au VimEnter * call NERDTreeHighlightFile('css',    '19',      'none', 'cyan',    'none')
au VimEnter * call NERDTreeHighlightFile('coffee', 'Red',     'none', 'red',     'none')
au VimEnter * call NERDTreeHighlightFile('java',   'Red',     'none', 'red',     'none')
au VimEnter * call NERDTreeHighlightFile('scala',  '198',     'none', '#ff0087', 'none')
au VimEnter * call NERDTreeHighlightFile('js',     'Red',     'none', '#ffa500', 'none')
au VimEnter * call NERDTreeHighlightFile('rb',     'Red',     'none', '#ffa500', 'none')
au VimEnter * call NERDTreeHighlightFile('php',    'Magenta', 'none', '#ff00ff', 'none')

