return {
  -- Tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  -- Catppuccin
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    -- TODO: PR to LazyVim
    opts = {
      flavour = "mocha",
      integrations = {
        dashboard = true,
        gitsigns = true,
        mason = true,
        mini = true,
        neotree = true,
        noice = true,
        cmp = true,
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
        navic = { enabled = true },
        treesitter = true,
        notify = true,
        telescope = true,
        lsp_trouble = true,
        illuminate = true,
        which_key = true,
      },
      custom_highlights = function(c)
        return {
          LeapMatch = { fg = c.pink, bold = true },
          LeapLabelPrimary = { fg = c.green, bold = true },
          LeapLabelSecondary = { fg = c.blue, bold = true },
          LeapBackdrop = { fg = c.overlay0 },
          NavicText = { fg = c.text, bg = c.none },
        }
      end,
    },
  },
}
