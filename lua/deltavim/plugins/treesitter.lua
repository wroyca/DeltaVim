local Keymap = require("deltavim.core.keymap")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- Last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSUpdateSync" },
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
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
          "jsdoc",
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
    end,
  },
}
