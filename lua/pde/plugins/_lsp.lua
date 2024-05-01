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
}
