---The default configuration.

local default = {
  ---@type string? the leader key to map before setting up Lazy
  mapleader = " ",

  ---@type string? the local leader key to map before setting up Lazy
  maplocalleader = "\\",

  ---@type boolean? whether to enable icons, default to `true`
  icons_enabled = true,

  ---@type table border for popups (hover, signature, etc)
  popup_border = { "", "", "", " ", "", "", "", " " },

  ---@type table border for float windows (LspInfo, Lazy, etc)
  float_border = { " ", " ", " ", " ", " ", " ", " ", " " },

  ---@class DeltaOptions.Autocmds
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

  ---@type table<string,string> lazy plugin names corresponding to DeltaVim module names
  plugin_names = { -- all 48 plugins
    -- core
    ["lazy"] = "lazy.nvim",
    ["deltavim"] = "deltavim",
    ["astrocore"] = "astrocore",
    ["astrolsp"] = "astrolsp",
    ["astroui"] = "astroui",
    -- coding
    ["cmp"] = "nvim-cmp",
    ["cmp-buffer"] = "cmp-buffer",
    ["cmp-nvim-lsp"] = "cmp-nvim-lsp",
    ["cmp-path"] = "cmp-path",
    ["cmp-luasnip"] = "cmp_luasnip",
    ["luasnip"] = "LuaSnip",
    ["autopairs"] = "nvim-autopairs",
    ["mini-comment"] = "mini.comment",
    -- lsp
    ["aerial"] = "aerial.nvim",
    ["lspconfig"] = "nvim-lspconfig",
    ["neoconf"] = "neoconf.nvim",
    ["neodev"] = "neodev.nvim",
    ["null-ls"] = "none-ls.nvim",
    -- treesitter
    ["treesitter"] = "nvim-treesitter",
    ["treesitter-textobjects"] = "nvim-treesitter-textobjects",
    ["ts-autotag"] = "nvim-ts-autotag",
    -- editor
    ["alpha"] = "alpha-nvim",
    ["colorizer"] = "nvim-colorizer.lua",
    ["dressing"] = "dressing.nvim",
    ["gitsigns"] = "gitsigns.nvim",
    ["heirline"] = "heirline.nvim",
    ["indent-blankline"] = "indent-blankline.nvim",
    ["mini-bufremove"] = "mini.bufremove",
    ["neo-tree"] = "neo-tree.nvim",
    ["nui"] = "nui.nvim",
    ["notify"] = "nvim-notify",
    ["telescope"] = "telescope.nvim",
    ["telescope-fzf-native"] = "telescope-fzf-native",
    ["todo-comments"] = "todo-comments.nvim",
    ["ufo"] = "nvim-ufo",
    ["which-key"] = "which-key.nvim",
    -- colorscheme
    ["astrotheme"] = "astrotheme",
    -- utility
    ["better-escape"] = "better-escape.nvim",
    ["guess-ident"] = "guess-ident.nvim",
    ["illuminate"] = "vim-illuminate",
    ["resession"] = "resession.nvim",
    ["smart-splits"] = "smart-splits.nvim",
    ["window-picker"] = "nvim-window-picker",
    ["plenary"] = "plenary.nvim",
    ["promise-async"] = "promise-async",
    ["web-devicons"] = "nivm-web-devicons",
  },
}

return default
