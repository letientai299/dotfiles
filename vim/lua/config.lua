require("ui")

vim.opt.shada = "!,'200,<500,s10,h"

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

-- Make available to vimscript mappings defined in after/plugin
_G.setup_oil = setup_oil

-- Setup oil on first directory open or Oil command
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "oil://*",
  once = true,
  callback = setup_oil,
})
-- Hijack directory buffers with oil (replaces netrw for `nvim .`)
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" and vim.fn.isdirectory(bufname) == 1 then
      setup_oil()
      vim.schedule(function()
        require("oil").open(bufname)
      end)
    end
  end,
})
vim.api.nvim_create_user_command("Oil", function(opts)
  setup_oil()
  require("oil").open(opts.args ~= "" and opts.args or nil)
end, { nargs = "?" })


-- Autocommands
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- AutoCopy: Toggleable copy on focus loss and buffer switch
local autocopy_enabled = false
local tracked_buf = nil
local autocopy_group = augroup("AutoCopy", { clear = true })

local function do_copy(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  vim.fn.setreg("+", content)
end

vim.api.nvim_create_user_command("AutoCopy", function()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)
  if buf_name == "" then buf_name = "unnamed buffer" else buf_name = vim.fn.fnamemodify(buf_name, ":t") end

  if autocopy_enabled and tracked_buf == current_buf then
    autocopy_enabled = false
    tracked_buf = nil
    vim.notify("AutoCopy OFF", vim.log.levels.INFO)
  else
    autocopy_enabled = true
    tracked_buf = current_buf
    vim.notify("AutoCopy ON: tracking [" .. buf_name .. "]", vim.log.levels.INFO)
    do_copy(current_buf)
  end
end, { desc = "Toggle AutoCopy" })

autocmd({ "FocusLost", "BufLeave", "WinLeave" }, {
  group = autocopy_group,
  callback = function()
    if autocopy_enabled and tracked_buf and vim.api.nvim_buf_is_valid(tracked_buf) then
      -- Only copy if we are leaving the tracked buffer
      local current_buf = vim.api.nvim_get_current_buf()
      if current_buf == tracked_buf then
        do_copy(tracked_buf)
      end
    end
  end,
  desc = "AutoCopy on focus loss or buffer/window switch",
})
