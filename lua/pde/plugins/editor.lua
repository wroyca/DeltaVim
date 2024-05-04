local plug = require "pde.utils.plug"

return {
  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable "git" == 1,
    event = "User AstroGitFile",
    opts = plug.opts "gitsigns",
  },

  {
    "stevearc/resession.nvim",
    lazy = true,
    dependencies = {
      { "AstroNvim/astrocore", opts = plug.autocmds "resession" },
    },
    opts = plug.opts "resession",
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        lazy = true,
        enabled = vim.fn.executable "make" == 1,
        build = "make",
      },
    },
    opts = plug.opts "telescope",
    config = plug.setup "telescope",
  },

  {
    "folke/todo-comments.nvim",
    event = "User AstroFile",
    cmd = { "TodoTrouble", "TodoTelescope", "TodoLocList", "TodoQuickFix" },
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    opts = {},
  },
}
