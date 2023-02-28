local M = {}

---@param opts? DeltaVim.Config
function M.setup(opts)
  require("deltavim.config").update(opts or {})
  require("deltavim.core.config").setup()
end

return M
