let g:formatdef_rustfmt_nightly='"rustup run nightly -- rustfmt --unstable-features"'
let g:formatters_rust = ["rustfmt_nightly"]

nnoremap <buffer> <leader>d <ESC>:CocCommand rust-analyzer.debug<cr>
nnoremap <buffer> <leader>r <ESC>:CocCommand rust-analyzer.run<cr>
nnoremap <buffer> gK <ESC>:CocCommand rust-analyzer.openDocs<cr>
