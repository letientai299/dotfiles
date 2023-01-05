require('ui')

--------------------------------------------------------------------------------
-- Tree sitter
--------------------------------------------------------------------------------
require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = {
    "c", "lua", "rust", "go", "tsx", "dart", "json", "kotlin"
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },

  highlight = {
    enable = true,
    disable = { "rust", "markdown" },
    additional_vim_regex_highlighting = false,
  },

  rainbow = {
    enable = true,
    -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    extended_mode = true,
  },

  incremental_selection = { enable = true },
  textobjects = { enable = true },
}


--------------------------------------------------------------------------------
-- Test UI
--------------------------------------------------------------------------------
-- require("neotest").setup({
-- adapters = {
-- require("neotest-rust"),
-- require("neotest-go"),
-- require("neotest-vim-test")({
-- ignore_file_types = { "rust", "go" },
-- }),
-- },
-- })

--------------------------------------------------------------------------------
-- Rest client
--------------------------------------------------------------------------------
-- require("rest-nvim").setup({
-- result_split_in_place = true
-- })
