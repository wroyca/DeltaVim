local Keymap = require("deltavim.core.keymap")

local load_textobjects = false
return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- Last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSUpdateSync" },
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter-textobjects" },
    keys = function()
      return Keymap.Collector()
        :map({
          { "@treesitter.icrement_selection", desc = "Icrement selection", mode = { "n", "x" } },
          { "@treesitter.decrement_selection", desc = "Decrement selection", mode = "x" },
        })
        :collect_lazy()
    end,
    opts = function()
      local mappings = Keymap.Collector()
        :map_unique({
          { "@treesitter.icrement_selection", "init_selection" },
          { "@treesitter.icrement_selection", "node_incremental" },
          { "@treesitter.decrement_selection", "node_decremental" },
        })
        :collect_rhs_table()
      return {
        ensure_installed = {
          "bash",
          "c",
          "html",
          "javascript",
          "json",
          "lua",
          "luadoc",
          "luap",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        highlight = { enable = true },
        indent = { enable = true },
        context_commentstring = { enable = true, enable_autocmd = false },
        incremental_selection = { enable = true, keymaps = mappings },
      }
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      if load_textobjects then
        -- No need to load the plugin, if we only need its queries for mini.ai
        if opts.textobjects then
          for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
            if opts.textobjects[mod] and opts.textobjects[mod].enable then
              local Loader = require("lazy.core.loader")
              Loader.disabled_rtp_plugins["nvim-treesitter-textobjects"] = nil
              local plugin = require("lazy.core.config").plugins["nvim-treesitter-textobjects"]
              require("lazy.core.loader").source_runtime(plugin.dir, "plugin")
              break
            end
          end
        end
      end
    end,
  },

  -- Text-objects queries used by other plugins like mini.ai
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    init = function()
      -- Disable rtp plugin, as we only need its queries for mini.ai. In case
      -- other textobject modules are enabled, we will load them once
      -- nvim-treesitter is loaded
      require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
      load_textobjects = true
    end,
  },
}
