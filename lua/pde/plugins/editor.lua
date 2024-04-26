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

  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable "git" == 1,
    event = "User AstroGitFile",
    opts = plug.opts "gitsigns",
  },
}
