local Keymap = require("deltavim.core.keymap")

return {
  -- Measure startuptime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function() vim.g.startuptime_tries = 10 end,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = {
        "buffers",
        "curdir",
        "tabpages",
        "winsize",
        "help",
        "globals",
      },
    },
    keys = function()
      ---@param cmd string
      ---@param args? any
      local function persistence(cmd, args)
        return function() require("persistence")[cmd](args) end
      end

      local function quit_silently()
        require("persistence").stop()
        vim.cmd.qa()
      end

      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets ={
        { "@session.quit_silently", quit_silently, "Quit without saving" },
        { "@session.restore", persistence("load"), "Restore session" },
        { "@session.restore_last", persistence("load", { last = true }), "Restore last session" },
        { "@session.stop", persistence("stop"), "Don't save current session" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
  },

  -- Library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },
}
