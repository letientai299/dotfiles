require("ui")

vim.opt.shada = "!,'200,<500,s10,h"

--------------------------------------------------------------------------------
-- Tree sitter
--------------------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all"
  ensure_installed = {
    "c",
    "lua",
    "rust",
    "go",
    "tsx",
    "dart",
    "json",
    "html",
    "toml",
    "css",
    "kotlin",
    "markdown",
  },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = { "rust", "markdown", "sql" },
    additional_vim_regex_highlighting = false,
  },
  rainbow = {
    enable = true,
    -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    extended_mode = true,
  },
  incremental_selection = { enable = true },
  textobjects = { enable = true },
})

--------------------------------------------------------------------------------
-- Other
--------------------------------------------------------------------------------
require("flatten").setup({
  window = {
    open = "alternate",
  },
})
require("better_escape").setup({
  mapping = { "jk" },         -- a table with mappings to use
  timeout = vim.o.timeoutlen, -- the time in which the keys must be hit in ms. Use option timeoutlen by default
  clear_empty_lines = false,  -- clear line after escaping if there is only whitespace
  keys = "<Esc>",             -- keys used for escaping, if it is a function will use the result everytime
  -- example(recommended)
  -- keys = function()
  --   return vim.api.nvim_win_get_cursor(0)[2] > 1 and '<esc>l' or '<esc>'
  -- end,
})

require("fzf-lua").setup({
  files = {
    cmd = 'fd --hidden --no-ignore-vcs'
  },
})

vim.api.nvim_create_user_command(
  'Helpfiles',
  function()
    require("fzf-lua").fzf_exec(
      "fd . --type f --extension=txt ~/.vim-plugged",
      {
        actions = {
          ['default'] = require 'fzf-lua'.actions.file_edit,
        }
      }
    )
  end,
  {}
)

--------------------------------------------------------------------------------
-- Test UI and tools
--------------------------------------------------------------------------------
-- require("neotest").setup({
-- adapters = {
-- -- require("neotest-rust"),
-- require("neotest-go"),
-- require("neotest-vim-test")({
-- ignore_file_types = { "go" },
-- }),
-- },
-- })


--------------------------------------------------------------------------------
-- Rest client
--------------------------------------------------------------------------------
-- require("rest-nvim").setup({
-- result_split_in_place = true
-- })
