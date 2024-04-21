local M = {}

---Merges one or more tables into `dst`.
---@param dst table
---@param ... table
---@return table
function M.merge(dst, ...)
  for _, tbl in ipairs { ... } do
    for k, v in pairs(tbl) do
      dst[k] = v
    end
  end
  return dst
end

M.deep_merge = require("lazy.core.util").merge

M.list_extend = vim.list_extend

return M
