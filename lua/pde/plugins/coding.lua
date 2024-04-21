local plug = require "pde.utils.plug"

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
    opts = plug.opts "cmp",
    config = plug.config "cmp",
  },

  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    dependencies = {
      { "rafamadriz/friendly-snippets", lazy = true },
      { "saadparwaiz1/cmp_luasnip", lazy = true },
    },
    opts = plug.opts "luasnip",
    config = plug.config "luasnip",
  },

  {
    "windwp/nvim-autopairs",
    event = "User AstroFile",
    opts = plug.opts "autopairs",
    config = plug.config "autopairs",
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
    keys = plug.keys "comment",
    opts = plug.opts "comment",
  },
}
