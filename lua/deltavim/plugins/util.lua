local Keymap = require("deltavim.core.keymap")

return {
  -- Measure startuptime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = function()
      ---@param cmd string
      ---@param args? any
      local function persistence(cmd, args)
        return function()
          require("persistence")[cmd](args)
        end
      end

      local function quit_silently()
        require("persistence").stop()
        vim.cmd.qa()
      end

      return Keymap.Collector()
        :map({
          { "@session.quit_silently", quit_silently, "Quit without saving" },
          { "@session.restore", persistence("load"), "Restore session" },
          { "@session.restore_last", persistence("load", { last = true }), "Restore last session" },
          { "@session.stop", persistence("stop"), "Don't save current session" },
        })
        :collect_lazy()
    end,
    opts = {
      options = {
        "buffers",
        "curdir",
        "globals",
        "help",
        "skiprtp",
        "tabpages",
        "winsize",
      },
    },
  },

  -- Library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },
}
