local Util = require("deltavim.util")

local M = {}

---Creates autocmds with the default.
---@param custom DeltaVim.Autocmd[]
---@return DeltaVim.Autocmd[]
function M.autocmds(custom)
  return Util.merge_lists(
    {},
    require("deltavim.config.autocmds").DEFAULT,
    custom
  )
end

---Creates keymaps with the default.
---@param custom DeltaVim.Keymap[]
---@return DeltaVim.Keymap[]
function M.keymaps(custom)
  return Util.merge_lists(
    {},
    require("deltavim.config.keymaps").DEFAULT,
    custom
  )
end

---Sets options with the default.
---@param custom fun()
---@return fun()
function M.options(custom)
  return function()
    require("deltavim.config.autocmds").DEFAULT()
    custom()
  end
end

M.setup = require("deltavim.core.config").setup

return M
