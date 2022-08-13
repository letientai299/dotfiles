let g:formatdef_rustfmt_nightly='"rustup run nightly -- rustfmt --unstable-features"'
let g:formatters_rust = ["rustfmt_nightly"]

nnoremap <leader>d <ESC>:CocCommand rust-analyzer.debug<cr>
nnoremap <leader>r <ESC>:CocCommand rust-analyzer.run<cr>
nnoremap gK <ESC>:CocCommand rust-analyzer.openDocs<cr>

set sw=2 ts=2 tw=80
