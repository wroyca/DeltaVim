return {
  "windwp/nvim-ts-autotag",
  event = "User AstroFile",
  opts = {},
  config = function(...) require "pde.plugins.configs.ts-autotag"(...) end,
}
