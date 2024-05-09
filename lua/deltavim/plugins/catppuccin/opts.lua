return {
  flavour = "mocha",
  integrations = {
    cmp = true,
    dashboard = true,
    gitsigns = true,
    illuminate = true,
    indent_blankline = { enabled = true },
    markdown = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
    neotree = true,
    notify = true,
    semantic_tokens = true,
    telescope = true,
    treesitter = true,
    which_key = true,
  },
  custom_highlights = require "deltavim.plugins.catppuccin.opts_highlights",
}
