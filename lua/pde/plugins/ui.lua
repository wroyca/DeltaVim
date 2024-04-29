local plug = require "pde.utils.plug"

return {
  {
    "AstroNvim/astroui",
    opts = plug.opts "astroui",
  },

  {
    "goolord/alpha-nvim",
    cmd = "Alpha",
    dependencies = {
      { "AstroNvim/astrocore", opts = plug.autocmds "alpha" },
    },
    opts = plug.opts "alpha",
    config = plug.config "alpha",
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = {
      { "AstroNvim/astrocore", opts = plug.autocmds "neo-tree" },
      { "nvim-lua/plenary.nvim", lazy = true },
      { "MunifTanjim/nui.nvim", lazy = true },
    },
    opts = plug.opts "neo-tree",
  },

  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    opts = plug.opts "heirline",
    config = plug.config "heirline",
  },
  { "echasnovski/mini.bufremove", lazy = true },
}
