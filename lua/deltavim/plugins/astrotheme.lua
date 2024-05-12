---@type LazyPluginSpec
return {
  "astrotheme",
  lazy = true,
  ---@type AstroThemeOpts
  opts = { plugins = { ["dashboard-nvim"] = true } },
}
