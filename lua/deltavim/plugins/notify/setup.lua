return function(_, opts)
  local notify = require "notify"
  notify.setup(opts)
  require("deltavim.notify").setup(notify)
end
