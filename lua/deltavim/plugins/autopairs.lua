---@type LazyPluginSpec
return {
  "windwp/nvim-autopairs",
  event = "User AstroFile",
  opts = {
    check_ts = true,
    ts_config = { java = false },
    fast_wrap = { map = "<C-Y>" },
  },
  config = function(_, opts)
    local npairs, astro = require "nvim-autopairs", require "astrocore"
    npairs.setup(opts)
    if not astro.config.features.autopairs then npairs.disable() end
  end,
}
