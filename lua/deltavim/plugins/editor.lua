local plug = require "deltavim.utils._plug"

---@type LazySpec
return {
  {
    "goolord/alpha-nvim",
    cmd = "Alpha",
    dependencies = {
      { "AstroNvim/astrocore", opts = plug.autocmds "alpha" },
    },
    opts = plug.opts "alpha",
    config = plug.setup "alpha",
  },

  {
    "NvChad/nvim-colorizer.lua",
    event = "User AstroFile",
    cmd = {
      "ColorizerToggle",
      "ColorizerAttachToBuffer",
      "ColorizerReloadAllBuffers",
    },
    opts = { user_default_options = { names = false } },
    config = plug.setup "colorizer",
  },

  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = plug.initialize "dressing",
    opts = plug.opts "dressing",
  },

  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable "git" == 1,
    event = "User AstroGitFile",
    opts = plug.opts "gitsigns",
  },

  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    opts = plug.opts "heirline",
    config = plug.setup "heirline",
  },
  { "echasnovski/mini.bufremove", lazy = true },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "User AstroFile",
    cmd = {
      "IBLEnable",
      "IBLDisable",
      "IBLToggle",
      "IBLEnableScope",
      "IBLDisableScope",
      "IBLToggleScope",
    },
    opts = plug.opts "indent-blankline",
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      { "AstroNvim/astrocore", opts = plug.autocmds "neo-tree" },
      { "MunifTanjim/nui.nvim", lazy = true },
    },
    opts = plug.opts "neo-tree",
  },

  {
    "rcarriga/nvim-notify",
    lazy = true,
    init = plug.initialize "notify",
    opts = plug.opts "notify",
    config = plug.setup "notify",
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        lazy = true,
        enabled = vim.fn.executable "make" == 1,
        build = "make",
      },
    },
    opts = plug.opts "telescope",
    config = plug.setup "telescope",
  },

  {
    "folke/todo-comments.nvim",
    event = "User AstroFile",
    cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
    opts = {
      highlight = { multiline = true },
    },
  },

  {
    "kevinhwang91/nvim-ufo",
    event = { "User AstroFile", "InsertEnter" },
    dependencies = {
      { "kevinhwang91/promise-async", lazy = true },
      {
        "AstroNvim/astrolsp",
        optional = true,
        opts = {
          capabilities = {
            textDocument = {
              foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
            },
          },
        },
      },
    },
    opts = plug.opts "ufo",
    config = plug.setup "ufo",
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = plug.opts "which-key",
  },
}
