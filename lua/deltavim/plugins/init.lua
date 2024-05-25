-- This file is loaded before all submodules under `deltavim/plugins/`, allowing
-- us to perform some initialization here.

local deltavim = require "deltavim"
deltavim.init()

---@type LazySpec
return {
  { "folke/lazy.nvim", dir = vim.env.LAZY },
  { "loichyan/DeltaVim", lazy = false, priority = 10000 },

  -- add an empty autocmds and mappings tables to prevent nil indexing errors
  {
    "astrocore",
    optional = true,
    opts = function() return { autocmds = {}, mappings = require("astrocore").empty_map_table() } end,
  },
  {
    "astrolsp",
    optional = true,
    opts = function() return { autocmds = {}, mappings = require("astrocore").empty_map_table() } end,
  },

  { import = "deltavim.snapshot", cond = deltavim.config.pin_plugins },
}
