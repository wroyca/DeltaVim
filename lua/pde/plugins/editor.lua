local plug = require "pde.utils.plug"

return {
  {
    "stevearc/resession.nvim",
    lazy = true,
    dependencies = {
      { "AstroNvim/astrocore", opts = plug.autocmds "resession" },
    },
    opts = plug.opts "resession",
  },
}
