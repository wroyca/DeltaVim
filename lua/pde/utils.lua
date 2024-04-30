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

---@type table<string,table> # cache for plugin mapping presets
local plugin_mappings = {}

---A handy function to bind mapping presets.
---@param dst table # the table to be set
---@param mappings table<string,table<string,string|table>>
---@return table # return `dst`
function M.make_mappings(dst, mappings)
  local plugin_names, astro = require("pde").config.plugin_names, require "astrocore"

  local unknowns = {}
  for mode, maps in pairs(mappings) do
    local dst_maps = dst[mode]
    for lhs, rhs in pairs(maps) do
      if type(rhs) == "string" then
        if not plugin_mappings[rhs] then -- lazy load mapping presets
          local module = vim.split(rhs, ".", { plain = true })[1]
          local plugin = plugin_names[module]
          -- only load presets when the plugin is available
          if not plugin or astro.is_available(plugin) then
            local ok, preset = pcall(require, "pde.mappings." .. module)
            if ok then
              for key, preset_rhs in pairs(preset) do -- insert all presets
                plugin_mappings[module .. "." .. key] = preset_rhs
              end
            end
          end
        end
        if not plugin_mappings[rhs] then table.insert(unknowns, rhs) end
        rhs = plugin_mappings[rhs]
      end

      if rhs then dst_maps[lhs] = rhs end
    end
  end

  if #unknowns > 0 then -- report unknown presets
    vim.notify("unknown mapping presets:\n" .. table.concat(unknowns, "\n"), vim.log.levels.ERROR)
  end
  return dst
end

---@param client lsp.Client
function M.formatting_enabled(client)
  if not client.supports_method "textDocument/formatting" then return false end
  local disabled = require("astrolsp").config.formatting.disabled
  return disabled ~= true and not vim.tbl_contains(disabled, client.name)
end

return M
