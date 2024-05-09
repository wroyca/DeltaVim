---@type LazySpec
return {
  {
    "AstroNvim/astrotheme",
    lazy = true,
    opts = { plugins = { ["dashboard-nvim"] = true } },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = require("deltavim.utils._plug").opts "catppuccin",
  },
}
