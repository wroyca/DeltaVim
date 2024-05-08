local plug = require "deltavim.utils.plug"

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "User AstroFile",
    cmd = {
      "TSBufEnable",
      "TSBufToggle",

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
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", lazy = true },
    },
    init = plug.initialize "treesitter",
    opts = plug.opts "treesitter",
    config = plug.setup "treesitter",
  },

  {
    "windwp/nvim-ts-autotag",
    event = "User AstroFile",
    dependencies = {
      {
        "AstroNvim/astrolsp",
        optional = true,
        opts = {
          lsp_handlers = {
            -- enable update in insert
            -- credit: https://github.com/windwp/nvim-ts-autotag/blob/531f483/README.md?plain=1#L57-L69
            ["textDocument/publishDiagnostics"] = vim.lsp.with(
              vim.lsp.diagnostic.on_publish_diagnostics,
              { update_in_insert = true }
            ),
          },
        },
      },
    },
    opts = {},
    config = plug.setup "ts-autotag",
  },
}
