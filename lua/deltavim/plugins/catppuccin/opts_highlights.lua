return function(c)
  return {
    HeirlineNormal = { bg = c.blue },
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
end
