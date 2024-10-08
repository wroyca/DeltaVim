---@module "nvim-window-picker"

---@type LazyPluginSpec
local Spec = {
  "s1n7ax/nvim-window-picker",
  lazy = true,
  opts = {
    picker_config = {
      statusline_winbar_picker = { use_winbar = "smart" },
    },
  },
}

return Spec
