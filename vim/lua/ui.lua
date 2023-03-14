--------------------------------------------------------------------------------
-- nightfox
--------------------------------------------------------------------------------
local nightfox = require("nightfox")
nightfox.setup({
  options = {
    dim_inactive = true,
    styles = {
      -- Style to be applied to different syntax groups
      comments = "italic", -- Value is any valid attr-list value `:help attr-list`
      constants = "bold",
      keywords = "italic",
    },
    modules = { -- List of various plugins and additional options
      -- ...
    },
  },
  palettes = {},
  specs = {},
  groups = {},
})

nightfox.compile()

--------------------------------------------------------------------------------
-- catppuccin
--------------------------------------------------------------------------------
vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

-- fetch colors from g:catppuccin_flavour palette
local colors = require("catppuccin.palettes").get_palette()
require("catppuccin").setup({
  custom_highlights = {
    ---@diagnostic disable-next-line: need-check-nil
    Comment = { fg = colors.lavender },
  },
  styles = {
    comments = { "italic" },
    keywords = { "italic" },
  },
  dim_inactive = {
    enabled = true,
    shade = "dark",
    percentage = 0.3,
  },
  compile = {
    enabled = true,
  },
  integration = {
    dap = {
      enabled = true,
      enable_ui = true,
    },
    which_key = true,
    neotree = {
      enabled = true,
      show_root = true,
      transparent_panel = true,
    },
    coc_nvim = true,
  },
})
vim.cmd([[sil CatppuccinCompile]])

--------------------------------------------------------------------------------
-- tokyonight
--------------------------------------------------------------------------------
vim.g.tokyonight_colors = { comment = "#8c9fee" }

--------------------------------------------------------------------------------
-- neotree
--------------------------------------------------------------------------------
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
require("neo-tree").setup({
  popup_border_style = "rounded", -- "double", "none", "rounded", "shadow", "single" or "solid"
  filesystem = {
    follow_current_file = true,
    use_libuv_file_watcher = true,
    window = {
      position = "float",
      mappings = {
        ["/"] = "none", -- this should use default vim text search
        ["]g"] = "none",
        ["[g"] = "none",
        ["[c"] = "prev_git_modified",
        ["]c"] = "next_git_modified",
        ["f"] = "fuzzy_finder",
        ["h"] = function(state)
          local node = state.tree:get_node()
          if node.type == 'directory' and node:is_expanded() then
            require 'neo-tree.sources.filesystem'.toggle_directory(state, node)
          else
            require 'neo-tree.ui.renderer'.focus_node(state, node:get_parent_id())
          end
        end,
        ["l"] = function(state)
          local node = state.tree:get_node()
          if node.type == 'directory' then
            if not node:is_expanded() then
              require 'neo-tree.sources.filesystem'.toggle_directory(state, node)
            elseif node:has_children() then
              require 'neo-tree.ui.renderer'.focus_node(state, node:get_child_ids()[1])
            end
          end
        end,
        ["Y"] = function(state)
          local node = state.tree:get_node()
          local content = node.path
          -- relative
          -- local content = node.path:gsub(state.path, ""):sub(2)
          vim.fn.setreg('"', content)
          vim.fn.setreg("1", content)
          vim.fn.setreg("+", content)
        end,
      }
    }
  }
})

--------------------------------------------------------------------------------
-- toggleterm
--------------------------------------------------------------------------------
require("toggleterm").setup({
  direction = "float",
  insert_mappings = true,
  float_opts = {
    border = "curved",
  },
  open_mapping = [[<a-q>]],
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.cmd([[DisableWhitespace]])
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

require("which-key").setup()

--------------------------------------------------------------------------------
-- Gitsign
--------------------------------------------------------------------------------
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })
  end
})

--------------------------------------------------------------------------------
-- misc
--------------------------------------------------------------------------------
-- should call these after set colorscheme
require('dressing').setup({})
require("bufferline").setup({})
require('lualine').setup({
  options = {
    component_separators = {},
    section_separators = {},
  }
})

require("indent_blankline").setup({
  show_current_context = true,
})
