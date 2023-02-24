local Util = require("deltavim.util")

local M = {}

---Creates autocmds with the default.
---@param custom DeltaVim.Autocmds
---@return DeltaVim.Autocmds
function M.autocmds(custom)
  return Util.merge_lists(
    {},
    require("deltavim.config.autocmds").DEFAULT,
    custom
  )
end

---Creates keymaps with the default.
---@param custom DeltaVim.Keymaps
---@return DeltaVim.Keymaps
function M.keymaps(custom)
  return Util.merge_lists(
    {},
    require("deltavim.config.keymaps").DEFAULT,
    custom
  )
end

---Sets options with the default.
---@param custom DeltaVim.Options
---@return DeltaVim.Options
function M.options(custom)
  return function(cfg)
    require("deltavim.config.options").DEFAULT()
    if type(custom) == "function" then
      return custom(cfg)
    else
      return custom
    end
  end
end

M.setup = require("deltavim.core.config").setup

return M
