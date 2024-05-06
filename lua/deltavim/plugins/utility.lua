local plug = require "deltavim.utils.plug"

---@type LazySpec
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
    "RRethy/vim-illuminate",
    event = "User AstroFile",
    opts = plug.opts "illuminate",
    config = plug.setup "illuminate",
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

  {
    "mrjones2014/smart-splits.nvim",
    lazy = true,
    opts = {
      ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
      ignored_buftypes = { "nofile" },
    },
  },
}
