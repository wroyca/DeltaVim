---The default configuration.

local default = {
  ---@type string? the leader key to map before setting up Lazy
  mapleader = " ",

  ---@type string? the local leader key to map before setting up Lazy
  maplocalleader = "\\",

  ---@type boolean? whether to enable icons, default to `true`
  icons_enabled = true,

  ---@class PdeOptions.Autocmds
  autocmds = {
    auto_quit = {
      ---@type table<string,boolean> filetypes considered as sidebars
      sidebar_filetypes = {
        ["aerial"] = true,
        ["neo-tree"] = true,
      },
    },

    auto_view = {
      ---@type table<string,boolean> filetypes not to be saved
      ignored_filetypes = {
        ["gitcommit"] = true,
        ["gitrebase"] = true,
        ["hgcommit"] = true,
        ["svg"] = true,
      },
    },

    q_close_windows = {
      ---@type table<string,boolean> filetypes to set the mapping
      filetypes = {
        ["help"] = true,
        ["nofile"] = true,
        ["qf"] = true,
        ["quickfix"] = true,
      },
    },

    unlist_buffers = {
      ---@type table<string,boolean> filetypes to be unlisted
      filetypes = {
        ["qf"] = true,
        ["quickfix"] = true,
      },
    },
  },

  ---@type table<string,string> lazy plugin names corresponding to PDE module names
  plugin_names = {
    -- core
    ["lazy"] = "lazy.nvim",
    ["pde"] = "pde",
    ["astrocore"] = "astrocore",
    -- coding
    ["cmp"] = "nvim-cmp",
    ["cmp-buffer"] = "cmp-buffer",
    ["cmp-path"] = "cmp-path",
    ["cmp-nvim-lsp"] = "cmp-nvim-lsp",
    ["cmp-luasnip"] = "cmp_luasnip",
    ["luasnip"] = "LuaSnip",
    ["autopairs"] = "nvim-autopairs",
    ["mini-comment"] = "mini.comment",
    -- editor
    ["resession"] = "resession.nvim",
    ["gitsigns"] = "gitsigns.nvim",
    -- lsp
    ["astrolsp"] = "astrolsp",
    -- ui
    ["astroui"] = "astroui",
    ["web-devicons"] = "nivm-web-devicons",
    ["alpha"] = "alpha-nvim",
    ["neo-tree"] = "neo-tree.nvim",
    ["heirline"] = "heirline.nvim",
    ["mini-bufremove"] = "mini.bufremove",
  },
}

return default
