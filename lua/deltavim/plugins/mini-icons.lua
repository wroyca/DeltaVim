---@module "mini.icons"

---@type LazyPluginSpec
return {
  "echasnovski/mini.icons",
  event = "VeryLazy",
  config = function(_, opts)
    local icons = require "mini.icons"
    icons.setup(opts)
    icons.mock_nvim_web_devicons()
  end,
}
