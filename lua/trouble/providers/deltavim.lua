-- HACK: https://github.com/folke/trouble.nvim/pull/274

local Util = require("trouble.util")

---@param options TroubleOptions
return function(_, buf, cb, options)
  local args = options.cmd_options
  if args.workspace then buf = nil end

  local items = {}

  local diags = vim.diagnostic.get(buf, options.cmd_options)
  for _, item in ipairs(diags) do
    table.insert(items, Util.process_item(item))
  end

  cb(items)
end
