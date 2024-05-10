return function()
  local lazy_notify = require "astronvim.lazy_notify"
  if vim.notify == lazy_notify.queue then vim.notify = lazy_notify.original end
  require("astrocore").load_plugin_with_func("nvim-notify", vim, "notify")
end
