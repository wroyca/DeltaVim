---@type LazyPluginSpec
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      icons = {
        group = vim.g.icons_enabled ~= false and "" or "+",
        separator = "-",
      },
      operators = { gc = "Comment toggle" },
      disable = { filetypes = { "TelescopePrompt" } },
      window = { border = require("deltavim").get_border "popup_border" },
    }
  end,
}
