return function()
  require("astrocore").load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" })
end
