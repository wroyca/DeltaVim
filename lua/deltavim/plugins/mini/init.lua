---@type LazyPluginSpec[]
local Spec = {
  { "echasnovski/mini.nvim", lazy = false },
  {
    -- PERF: Avoid cloning each module individually since they are bundled together with mini.nvim.
    import = "deltavim.plugins.mini",
  },
}

return not package.loaded["mini"] and Spec or {}
