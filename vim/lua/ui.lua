--------------------------------------------------------------------------------
-- noice
--------------------------------------------------------------------------------
-- require("notify").setup({
-- background_colour = "#000000",
-- })

-- require("noice").setup({
-- cmdline = {
-- view = "cmdline"
-- },
-- lsp = {
-- override = {
-- ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
-- ["vim.lsp.util.stylize_markdown"] = true,
-- ["cmp.entry.get_documentation"] = true,
-- },
-- },
-- presets = {
-- bottom_search = true,         -- use a classic bottom cmdline for search
-- long_message_to_split = true, -- long messages will be sent to a split
-- inc_rename = true,            -- enables an input dialog for inc-rename.nvim
-- lsp_doc_border = true,        -- add a border to hover docs and signature help
-- },
-- -- Show @recording messages
-- routes = {
-- {
-- filter = {
-- event = "msg_show",
-- kind = "",
-- find = "written",
-- },
-- opts = { skip = true },
-- },
-- },
-- })

--------------------------------------------------------------------------------
-- alpha
--------------------------------------------------------------------------------
local alpha = require('alpha')
local cfg = require 'alpha.themes.startify'
cfg.section.header.val = {}
alpha.setup(cfg.config)

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
  transparent_background = true,
  custom_highlights = {
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
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
      show_end_of_line = true,
      show_trailing_blankline_indent = true,
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
require("tokyonight").setup({
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = "transparent",
    floats = "transparent",
  },
  sidebars = { "qf", "vista_kind", "terminal", "neo-tree" },
  transparent = true, -- Enable this to disable setting the background color
  hide_inactive_statusline = false,
  dim_inactive = true,
})

--------------------------------------------------------------------------------
-- neotree
--------------------------------------------------------------------------------
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
require("neo-tree").setup({
  popup_border_style = "rounded", -- "double", "none", "rounded", "shadow", "single" or "solid"
  filesystem = {
    follow_current_file = {
      enabled = true,
    },
    use_libuv_file_watcher = true,
    commands = {
      expand_node = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" then
          if not node:is_expanded() then
            require("neo-tree.sources.filesystem").toggle_directory(state, node)
          elseif node:has_children() then
            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
          end
        end
      end,
      close_node = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" and node:is_expanded() then
          require("neo-tree.sources.filesystem").toggle_directory(state, node)
        else
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
        end
      end,
      yank_path = function(state)
        local node = state.tree:get_node()
        local content = node.path
        -- relative
        -- local content = node.path:gsub(state.path, ""):sub(2)
        vim.fn.setreg('"', content)
        vim.fn.setreg("1", content)
        vim.fn.setreg("+", content)
      end,
    },
    window = {
      position = vim.g.neovide and "left" or "float",
      mappings = {
        ["/"] = "none", -- this should use default vim text search
        ["]g"] = "none",
        ["[g"] = "none",
        ["[c"] = "prev_git_modified",
        ["]c"] = "next_git_modified",
        ["f"] = "fuzzy_finder",
        ["h"] = "close_node",
        ["l"] = "expand_node",
        ["Y"] = "yank_path",
      },
    },
  },
})

--------------------------------------------------------------------------------
-- toggleterm
--------------------------------------------------------------------------------
require("toggleterm").setup({
  direction = vim.g.neovide and "horizontal" or "float",
  insert_mappings = true,
  float_opts = {
    border = "curved",
  },
  open_mapping = [[<c-q>]],
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
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Keymaps
    map("n", "<leader>th", gs.preview_hunk)
    map("n", "<leader>tb", function()
      gs.blame_line({ full = true })
    end)

    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })
  end,
})

--------------------------------------------------------------------------------
-- icons
--------------------------------------------------------------------------------
require 'nvim-web-devicons'.setup {
  color_icons = true,

  default = true,

  override_by_extension = {
    ["rkt"] = {
      icon = "󰘧",
      color = "#f94449",
      name = "Racket",
    }
  },
}

--------------------------------------------------------------------------------
-- misc
--------------------------------------------------------------------------------
-- should call these after set colorscheme
require("todo-comments").setup({
  highlight = {
    pattern = [[.*<(KEYWORDS).*:?]],
    comments_only = false,
  },

  colors = {
    info = { "#34eb92" },
  },

  search = {
    pattern = [[\b(KEYWORDS)\b.*:?]]
  },
})


-- require("dressing").setup({})
require("bufferline").setup({})

require("lualine").setup({
  options = {
    component_separators = {},
    section_separators = {},
  },
})

require("ibl").setup {}
