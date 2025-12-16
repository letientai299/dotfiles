require("ui")

vim.opt.shada = "!,'200,<500,s10,h"

--------------------------------------------------------------------------------
-- PERF: Treesitter - Defer setup to first buffer with a filetype
-- This saves ~6ms at startup by not loading treesitter immediately
--------------------------------------------------------------------------------
local treesitter_configured = false
local function setup_treesitter()
  if treesitter_configured then return end
  treesitter_configured = true

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
      -- PERF: Set to false for better performance.
      -- When true, BOTH treesitter AND vim regex highlighting run simultaneously,
      -- which is slower. Treesitter alone provides accurate highlighting.
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true
    },
    rainbow = {
      enable = true,
      extended_mode = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-s>",
        node_incremental = "<C-s>",
        node_decremental = "<M-s>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
        },
      }
    },
  })
end

-- Trigger treesitter setup on first file open
vim.api.nvim_create_autocmd("FileType", {
  once = true,
  callback = function()
    vim.schedule(setup_treesitter)
  end,
})

--------------------------------------------------------------------------------
-- Other
--------------------------------------------------------------------------------
require("flatten").setup({
  window = {
    open = "alternate",
  },
})

-- PERF: better_escape needs to be available immediately for jk escape
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

--------------------------------------------------------------------------------
-- PERF: fzf-lua - Defer setup until first use
-- This saves ~7ms at startup. Setup runs on first fzf command.
--------------------------------------------------------------------------------
local fzf_configured = false
local function setup_fzf()
  if fzf_configured then return end
  fzf_configured = true
  require("fzf-lua").setup({
    files = {
      cmd = 'fd --hidden --no-ignore-vcs -E .git -E .idea -E node_modules'
    },
  })
end

-- Create wrapper commands that trigger setup
vim.api.nvim_create_user_command('FzfLua', function(opts)
  setup_fzf()
  require('fzf-lua')[opts.args ~= '' and opts.args or 'builtin']()
end, { nargs = '?' })

vim.api.nvim_create_user_command(
  'Helpfiles',
  function()
    setup_fzf()
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

--------------------------------------------------------------------------------
-- PERF: Oil file manager - defer setup until first use
-- Oil is only needed when browsing directories
--------------------------------------------------------------------------------
local oil_configured = false
local function setup_oil()
  if oil_configured then return end
  oil_configured = true

  local oil_file_detail = false
  require("oil").setup({
    view_options = {
      show_hidden = true,
    },
    delete_to_trash = false,
    skip_confirm_for_simple_edits = true,
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
end

-- Setup oil on first directory open or Oil command
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "oil://*",
  once = true,
  callback = setup_oil,
})
vim.api.nvim_create_user_command("Oil", function(opts)
  setup_oil()
  require("oil").open(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })
