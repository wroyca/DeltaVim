local plug = require "pde.utils.plug"

return {
  {
    "AstroNvim/astroui",
    opts = plug.opts "astroui",
  },

  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
    enabled = vim.g.icons_enabled ~= false,
    opts = plug.opts "web-devicons",
  },

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
    "rebelot/heirline.nvim",
    event = "BufEnter",
    opts = plug.opts "heirline",
    config = plug.setup "heirline",
  },
  { "echasnovski/mini.bufremove", lazy = true },

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
}
