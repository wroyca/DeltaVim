local Keymap = require("deltavim.core.keymap")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- Last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    cmd = { "TSUpdate", "TSUpdateSync" },
    event = { "VeryLazy", "BufReadPost", "BufNewFile" },
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

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    config = function()
      -- When in diff mode, we want to use the default vim text objects c & C
      -- instead of the treesitter ones.
      local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.configs")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },

  -- Show context of the current function
  -- {
  --   "nvim-treesitter/nvim-treesitter-context",
  --   event = "LazyFile",
  --   enabled = true,
  --   opts = { mode = "cursor" },
  -- },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
