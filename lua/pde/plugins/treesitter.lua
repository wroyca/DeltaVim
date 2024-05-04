local plug = require "pde.utils.plug"

return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "User AstroFile",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",

      "TSDisable",
      "TSEnable",
      "TSToggle",

      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",

      "TSModuleInfo",
    },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
    },
    build = ":TSUpdate",
    init = plug.initialize "treesitter",
    opts = plug.opts "treesitter",
    config = plug.setup "treesitter",
  },

  {
    "windwp/nvim-ts-autotag",
    event = "User AstroFile",
    opts = {},
    config = plug.setup "ts-autotag",
  },
}
