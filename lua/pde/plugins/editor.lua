return {
  {
    "stevearc/resession.nvim",
    lazy = true,
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          require("pde.utils").merge(opts.autocmds, require "pde.autocmds.resession")
        end,
      },
    },
    opts = function() return require "pde.options.resession" end,
  },
}
