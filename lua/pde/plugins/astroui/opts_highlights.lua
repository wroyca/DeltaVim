return {
  init = function()
    local hlgroup = require("astroui").get_hlgroup

    local Error = hlgroup("Error").fg
    local Normal = hlgroup "Normal"
    local String = hlgroup("String").fg

    local fg, bg = Normal.fg, Normal.bg
    local bg_alt = hlgroup("Visual").bg

    return {
      -- NvChad style telescope theme
      -- credit: https://github.com/AstroNvim/astrocommunity/blob/23d141b/lua/astrocommunity/recipes/telescope-nvchad-theme/init.lua#L21-L32
      TelescopeBorder = { fg = bg_alt, bg = bg },
      TelescopeNormal = { bg = bg },
      TelescopePreviewBorder = { fg = bg, bg = bg },
      TelescopePreviewNormal = { bg = bg },
      TelescopePreviewTitle = { fg = bg, bg = String },
      TelescopePromptBorder = { fg = bg_alt, bg = bg_alt },
      TelescopePromptNormal = { fg = fg, bg = bg_alt },
      TelescopePromptPrefix = { fg = Error, bg = bg_alt },
      TelescopePromptTitle = { fg = bg, bg = Error },
      TelescopeResultsBorder = { fg = bg, bg = bg },
      TelescopeResultsNormal = { bg = bg },
      TelescopeResultsTitle = { fg = bg, bg = bg },
    }
  end,
}
