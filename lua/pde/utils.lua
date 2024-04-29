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

---Get the highlight group of the lualine theme for the current colorscheme.
---@param theme string
---@return (fun(mode: string, comp: string): table?)?
function M.make_lualine_hl(theme)
  local ok, lualine = pcall(require, "lualine.themes." .. theme)
  if not ok then return end

  return function(mode, comp)
    local mode_hl = lualine[mode]
    local comp_hl = mode_hl and type(mode_hl[comp]) == "table" and mode_hl[comp] or nil
    if not comp_hl then return end
    return { fg = comp_hl.fg, bg = comp_hl.bg }
  end
end

return M
