---@type LazyPluginSpec
local Spec = {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = true,
  ---@type CatppuccinOptions
  opts = {
    flavour = "mocha",
    integrations = {
      aerial = true,
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
      telescope = { enabled = true },
      treesitter = true,
      ufo = true,
      which_key = true,
      window_picker = true,
    },
    custom_highlights = function(c)
      return {
        NormalFloat = { fg = c.text, bg = c.surface0 },
        FloatBorder = { fg = c.text, bg = c.surface0 },

        HeirlineNormal = { fg = c.surface0, bg = c.blue },
        HeirlineInsert = { bg = c.green },
        HeirlineTerminal = { bg = c.green },
        HeirlineCommand = { bg = c.peach },
        HeirlineVisual = { bg = c.mauve },
        HeirlineReplace = { bg = c.red },
        HeirlineInactive = { bg = c.red },
        HeirlineButton = { fg = c.text, bg = c.surface0 },
        HeirlineText = { fg = c.overlay0 },

        LspInlayHint = { fg = c.surface1, italic = true },
      }
    end,
  },
}

return Spec
