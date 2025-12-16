require("ui")

vim.opt.shada = "!,'200,<500,s10,h"

--------------------------------------------------------------------------------
-- Treesitter setup
-- Note: nvim-treesitter main branch uses new API
-- Run :PlugUpdate to update nvim-treesitter-textobjects to main branch
--------------------------------------------------------------------------------
-- Basic treesitter config (new API)
require("nvim-treesitter").setup({
  -- install_dir can be customized if needed
})

-- Configure folding with treesitter (set in vimrc, just ensure foldexpr is right)
-- Highlighting is enabled automatically per-buffer when a parser is available

-- Textobjects setup - requires main branch of textobjects
-- After running :PlugUpdate, configure textobjects here if needed
local ok, ts_textobjects = pcall(require, "nvim-treesitter-textobjects")
if ok and ts_textobjects.setup then
  ts_textobjects.setup({
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
      },
    },
  })
end

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

-- Make setup_oil globally accessible for keymaps
_G.setup_oil = setup_oil
