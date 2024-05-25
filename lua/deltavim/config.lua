---The default configuration.

---@class DeltaOptions
local M = {
  ---@type string the leader key to map before setting up Lazy
  mapleader = " ",

  ---@type string the local leader key to map before setting up Lazy
  maplocalleader = "\\",

  ---@type boolean whether to enable icons, default to `true`
  icons_enabled = true,

  ---@type boolean whether to pin plugins or not, default is true
  pin_plugins = true,

  ---@type table border for popups (hover, signature, etc)
  popup_border = { "", "", "", " ", "", "", "", " " },

  ---@type table border for float windows (LspInfo, Lazy, etc)
  float_border = { " ", " ", " ", " ", " ", " ", " ", " " },

  ---@class DeltaOptions.Autocmds
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
        ["checkhealth"] = true,
        ["git"] = true,
        ["help"] = true,
        ["lspinfo"] = true,
        ["man"] = true,
        ["neotest-output"] = true,
        ["neotest-output-panel"] = true,
        ["neotest-summary"] = true,
        ["nofile"] = true,
        ["notify"] = true,
        ["null-ls-info"] = true,
        ["PlenaryTestPopup"] = true,
        ["qf"] = true,
        ["query"] = true,
        ["quickfix"] = true,
        ["spectre_panel"] = true,
        ["startuptime"] = true,
        ["tsplayground"] = true,
        ["TelescopePrompt"] = true,
        ["vim"] = true,
      },
    },

    unlist_buffers = {
      ---@type table<string,boolean> filetypes to be unlisted
      filetypes = {
        ["qf"] = true,
        ["quickfix"] = true,
      },
    },
  },
}

return M
