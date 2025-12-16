" PERF: fzf-lua keymaps - these trigger lazy loading via lua wrapper functions
" The actual fzf-lua setup happens on first use (saves ~7ms at startup)

" Helper function to lazy-load fzf and fzf-lua then call a method
function! s:fzf_call(method) abort
  " Ensure fzf and fzf-lua are loaded first (both are lazy-loaded via vim-plug)
  if !exists('g:loaded_fzf')
    call plug#load('fzf')
  endif
  if !exists('g:loaded_fzf_lua')
    call plug#load('fzf-lua')
  endif
  lua << EOF
    local fzf = require('fzf-lua')
    -- Ensure setup is called (idempotent check)
    if not _G._fzf_configured then
      _G._fzf_configured = true
      fzf.setup({
        files = {
          cmd = 'fd --hidden --no-ignore-vcs -E .git -E .idea -E node_modules'
        },
      })
    end
EOF
  execute 'lua require("fzf-lua").' . a:method . '()'
endfunction

nmap <D-f> :call <SID>fzf_call('buffers')<CR>
nmap <leader>fa :call <SID>fzf_call('builtin')<CR>
nmap <leader>fc :call <SID>fzf_call('git_bcommits')<CR>
nmap <leader>fC :call <SID>fzf_call('git_commits')<CR>
nmap <leader>fF :call <SID>fzf_call('git_files')<CR>
nmap <leader>ff :call <SID>fzf_call('files')<CR>
nmap <leader>fm :call <SID>fzf_call('keymaps')<CR>
nmap <leader>fx :call <SID>fzf_call('commands')<CR>
nmap <leader>fg :call <SID>fzf_call('live_grep_native')<CR>
nmap <leader>fh :call <SID>fzf_call('oldfiles')<CR>
nmap <leader>f' :call <SID>fzf_call('marks')<CR>

" PERF: Defer ui_select registration - only register when vim.ui.select is called
" This avoids loading fzf-lua at startup just for ui_select
lua << EOF
  local original_ui_select = vim.ui.select
  vim.ui.select = function(items, opts, on_choice)
    -- Replace with fzf-lua on first call
    require('fzf-lua').register_ui_select()
    -- Call the now-registered fzf-lua ui.select
    vim.ui.select(items, opts, on_choice)
  end
EOF

