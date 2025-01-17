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
    "markdown_inline",
  },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  auto_install = true,
  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = { "vim" },
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = true
  },
  rainbow = {
    enable = true,
    -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    extended_mode = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-m>",
      node_incremental = "<C-m>",
      node_decremental = "<M-m>",
    },
  },
  textobjects = {
    select = {
      enable = true,
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
      },
    }
  },
})

--------------------------------------------------------------------------------
-- Other
--------------------------------------------------------------------------------
require("flatten").setup({
  window = {
    open = "alternate",
  },
})

-- lua, default settings
require("better_escape").setup {
  timeout = vim.o.timeoutlen,
  mappings = {
    i = { j = { k = "<Esc>" } },
    c = { j = { k = "<Esc>" } },
    t = { j = { k = "<Esc>" } },
    v = { j = { k = "<Esc>" } },
    s = { j = { k = "<Esc>" } },
  },
}

require("fzf-lua").setup({
  files = {
    cmd = 'fd --hidden --no-ignore-vcs -E .git -E .idea -E node_modules'
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

local oil_file_detail = false
require("oil").setup({
  columns = {
    "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },
  keymaps = {
    ['yp'] = {
      desc = 'Copy filepath to system clipboard',
      callback = function()
        require('oil.actions').copy_entry_path.callback()
        vim.fn.setreg("+", vim.fn.getreg(vim.v.register))
      end,
    },

    ["gd"] = {
      desc = "Toggle file detail view",
      callback = function()
        oil_file_detail = not oil_file_detail
        if oil_file_detail then
          require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
        else
          require("oil").set_columns({ "icon" })
        end
      end,
    },
  },
})
