return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "hrsh7th/cmp-buffer", lazy = true },
      { "hrsh7th/cmp-path", lazy = true },
      {
        "hrsh7th/cmp-nvim-lsp",
        lazy = true,
        dependencies = {
          "AstroNvim/astrolsp",
          optional = true,
          opts = {
            capabilities = {
              textDocument = {
                completion = {
                  completionItem = {
                    documentationFormat = { "markdown", "plaintext" },
                    snippetSupport = true,
                    preselectSupport = true,
                    insertReplaceSupport = true,
                    labelDetailsSupport = true,
                    deprecatedSupport = true,
                    commitCharactersSupport = true,
                    tagSupport = { valueSet = { 1 } },
                    resolveSupport = {
                      properties = { "documentation", "detail", "additionalTextEdits" },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
    opts = function() return require "pde.options.cmp" end,
    config = function(...) require "pde.setups.cmp"(...) end,
  },

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    dependencies = {
      { "rafamadriz/friendly-snippets", lazy = true },
      { "saadparwaiz1/cmp_luasnip", lazy = true },
    },
    opts = function() return require "pde.options.luasnip" end,
    config = function(...) require "pde.setups.luasnip"(...) end,
  },

  {
    "windwp/nvim-autopairs",
    event = "User AstroFile",
    opts = function() return require "pde.options.autopairs" end,
    config = function(...) require "pde.setups.autopairs"(...) end,
  },

  {
    "echasnovski/mini.comment",
    dependencies = {
      {
        "JoosepAlviste/nvim-ts-context-commentstring",
        lazy = true,
        opts = { enable_autocmd = false },
      },
    },
    keys = function() return require "pde.keys.comment" end,
    opts = function() return require "pde.options.comment" end,
  },
}
