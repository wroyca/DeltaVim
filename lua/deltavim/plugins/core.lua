return {
  { "folke/lazy.nvim", version = "*" },
  {
    "DeltaVim",
    priority = 10000,
    lazy = false,
    version = "*",
    config = function() require("deltavim").setup() end,
  },
}
