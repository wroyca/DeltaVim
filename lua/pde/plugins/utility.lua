local plug = require "pde.utils.plug"

return {
  {
    "max397574/better-escape.nvim",
    event = "InsertCharPre",
    opts = { timeout = 300 },
  },

  {
    "NMAC427/guess-indent.nvim",
    event = "User AstroFile",
  },

  {
    "s1n7ax/nvim-window-picker",
    lazy = true,
    opts = {
      picker_config = {
        statusline_winbar_picker = { use_winbar = "smart" },
      },
    },
  },
}
