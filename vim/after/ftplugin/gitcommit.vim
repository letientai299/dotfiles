" Git commit message best practices (minimal config, no custom functions)
" Vim's built-in gitcommit ftplugin already handles most best practices.

" Visual guides: 50 for subject, 72 for body
setlocal colorcolumn=51,73

" Enable spell checking
setlocal spell

" Hybrid filetype: gitcommit syntax + markdown syntax for body
setlocal filetype=gitcommit.markdown

" Use gq to manually format selected text at 72 chars (built-in)
