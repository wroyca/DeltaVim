local Keymap = require("deltavim.core.keymap")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- Last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter-textobjects" },
    keys = function()
      -- stylua: ignore
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
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },

  -- Text-objects queries used by other plugins like mini.ai
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    init = function()
      -- No need to load the plugin, if we only need its queries for mini.ai
      local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local enabled = false
      if opts.textobjects then
        for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
          if opts.textobjects[mod] and opts.textobjects[mod].enable then
            enabled = true
            break
          end
        end
      end
      if not enabled then
        -- stylua: ignore
        require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
      end
    end,
  },
}
