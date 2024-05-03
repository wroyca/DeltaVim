local plug = require "pde.utils.plug"

return {
  {
    "AstroNvim/astrolsp",
    lazy = true,
    opts = plug.opts "astrolsp",
  },

  {
    "stevearc/aerial.nvim",
    event = "User AstroFile",
    opts = plug.opts "aerial",
  },

  {
    "neovim/nvim-lspconfig",
    event = "User AstroFile",
    cmd = { "LspInfo", "LspLog", "LspStart" },
    config = plug.setup "lspconfig",
  },
  { "folke/neodev.nvim", lazy = true, opts = {} },

  {
    "nvimtools/none-ls.nvim",
    main = "null-ls",
    event = "User AstroFile",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    opts = function() return { on_attach = require("astrolsp").on_attach } end,
  },
}
