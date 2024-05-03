local plug = require "pde.utils.plug"
require("pde").init()

return {
  { "folke/lazy.nvim", dir = vim.env.LAZY },
  { "loichyan/pde", lazy = false, priority = 10000 },

  {
    "AstroNvim/astrocore",
    lazy = false,
    priority = 10000,
    dependencies = { "AstroNvim/astroui" },
    opts = plug.opts "astrocore",
  },

  {
    "AstroNvim/astrolsp",
    lazy = true,
    opts = plug.opts "astrolsp",
  },

  {
    "AstroNvim/astroui",
    lazy = true,
    opts = plug.opts "astroui",
  },
}
