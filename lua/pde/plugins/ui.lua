return {
  {
    "goolord/alpha-nvim",
    cmd = "Alpha",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          require("pde.utils").merge(opts.autocmds, require "pde.autocmds.alpha")
        end,
      },
    },
    opts = function() return require "pde.options.alpha" end,
    config = function(...) require "pde.setups.alpha"(...) end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          require("pde.utils").merge(opts.autocmds, require "pde.autocmds.neo-tree")
        end,
      },
      { "nvim-lua/plenary.nvim", lazy = true },
      { "MunifTanjim/nui.nvim", lazy = true },
    },
    opts = function() return require "pde.options.neo-tree" end,
  },
}
