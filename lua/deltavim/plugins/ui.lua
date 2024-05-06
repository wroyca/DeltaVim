local plug = require "deltavim.utils.plug"

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
      "ColorizerDetachFromBuffer",
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
      { "nvim-lua/plenary.nvim", lazy = true },
      { "MunifTanjim/nui.nvim", lazy = true },
    },
    opts = plug.opts "neo-tree",
  },

  {
    "rcarriga/nvim-notify",
    lazy = true,
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.n["<Leader>uD"] = {
            function() require("notify").dismiss { pending = true, silent = true } end,
            desc = "Dismiss notifications",
          }
        end,
      },
    },
    init = plug.initialize "notify",
    opts = plug.opts "notify",
    config = plug.setup "notify",
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

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    enabled = vim.g.icons_enabled ~= false,
    opts = plug.opts "web-devicons",
  },
}
