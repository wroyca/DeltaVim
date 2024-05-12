---@type LazyPluginSpec
return {
  "hrsh7th/cmp-nvim-lsp",
  lazy = true,
  dependencies = {
    {
      "astrolsp",
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
}
