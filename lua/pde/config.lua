---@class PdeOptions
local defaults = {
  ---@type string? the leader key to map before setting up Lazy
  mapleader = " ",

  ---@type string? the local leader key to map before setting up Lazy
  maplocalleader = ",",

  ---@type boolean? whether to enable icons, default to `true`
  icons_enabled = true,

  ---@class PdeOptions.Autocmds
  autocmds = {
    auto_quit = {
      ---@type table<string,boolean> filetypes considered as sidebars
      sidebar_filetypes = {
        ["aerial"] = true,
        ["neo-tree"] = true,
      },
    },

    auto_view = {
      ---@type table<string,boolean> filetypes not to be saved
      ignored_filetypes = {
        ["gitcommit"] = true,
        ["gitrebase"] = true,
        ["hgcommit"] = true,
        ["svg"] = true,
      },
    },

    q_close_windows = {
      ---@type table<string,boolean> filetypes to set the mapping
      filetypes = {
        ["help"] = true,
        ["nofile"] = true,
        ["quickfix"] = true,
      },
    },

    unlist_buffers = {
      ---@type table<string,boolean> filetypes to be unlisted
      filetypes = {
        ["quickfix"] = true,
      },
    },
  },
}

return defaults
