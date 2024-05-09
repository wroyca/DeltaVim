local M = {}

---@param name string
---@return function
function M.opts(name)
  local mod = "deltavim.plugins." .. name .. ".opts"
  return function(_, opts) return require("deltavim.utils").deep_merge(opts, require(mod)) end
end

---@param name string
---@return function
function M.keys(name)
  local mod = "deltavim.plugins." .. name .. ".keys"
  return function(_, keys) return require("deltavim.utils").concat(keys, require(mod)) end
end

---@param name string
---@return function
function M.setup(name)
  local mod = "deltavim.plugins." .. name .. ".setup"
  return function(...) return require(mod)(...) end
end

---@param name string
---@return function
function M.initialize(name)
  local mod = "deltavim.plugins." .. name .. ".initialize"
  return function(...) return require(mod)(...) end
end

---@param name string
---@return function
function M.autocmds(name)
  local mod = "deltavim.plugins." .. name .. ".autocmds"
  return function(_, opts)
    opts.autocmds = require("deltavim.utils").merge(opts.autocmds or {}, require(mod))
    return opts
  end
end

return M
