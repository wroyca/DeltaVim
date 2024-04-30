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

---A handy function to bind mapping presets.
---@param dst table # the table to be set
---@param mappings table<string,table<string,table<string,string|table>>>
---@return table # return `dst`
function M.make_mappings(dst, mappings)
  local plugin_names, astro = require("pde").config.plugin_names, require "astrocore"

  local unknowns = {}
  for module, mode_maps in pairs(mappings) do
    local plugin = plugin_names[module]
    -- only set mappings when a plugin is available
    if not plugin or astro.is_available(plugin) then
      local ok, preset = pcall(require, "pde.mappings." .. module)
      if not ok then table.insert(unknowns, module) end

      for mode, maps in pairs(mode_maps) do
        local dst_maps = dst[mode]
        for key, rhs in pairs(maps) do
          if type(rhs) == "string" then -- strings are treated as preset key
            if not preset[rhs] then table.insert(unknowns, module .. "." .. rhs) end
            rhs = preset[rhs]
          end
          if rhs then dst_maps[key] = rhs end
        end
      end
    end
  end

  if #unknowns > 0 then -- report unknown presets
    vim.notify("unknown mapping presets:\n" .. table.concat(unknowns, "\n"), vim.log.levels.ERROR)
  end
  return dst
end

return M
