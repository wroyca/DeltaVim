---@module "telescope-fzf-native"

---@type LazyPluginSpec
return {
  "nvim-telescope/telescope-fzf-native.nvim",
  lazy = true,
  enabled = vim.fn.executable "make" == 1,
  build = "make",
}
