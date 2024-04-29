local plug = require "pde.utils.plug"
require("pde").init()

return {
  { "folke/lazy.nvim", dir = vim.env.LAZY },
  {
    "loichyan/pde",
    lazy = false,
    priority = 10000,
    init = function() require("pde").init() end,
  },
  {
    "AstroNvim/astrocore",
    lazy = false,
    priority = 10000,
    dependencies = { "AstroNvim/astroui" },
    opts = plug.opts "astrocore",
  },
}
