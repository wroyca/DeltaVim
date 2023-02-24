local Autocmd = require("deltavim.core.autocmd")
local LazyUtil = require("lazy.core.util")
local Log = require("deltavim.core.log")

local M = {
  try = LazyUtil.try,
}

---@generic T
---@param f fun():T?
---@param opts? {msg?:string,on_error?:fun(err:any)}|string
---@return boolean, T|nil
function M.try(f, opts)
  if type(opts) == "string" then
    opts = { msg = opts }
  else
    opts = opts or { msg = "An error occurs: %s" }
  end
  local msg = opts.msg
  local on_error = opts.on_error
  local ok, ret = pcall(f)
  if ok then return true, ret end
  if msg then Log.error(msg, ret) end
  if on_error then on_error(ret) end
  return false
end

---Registers a callback on the VeryLazy event.
---@param cb DeltaVim.Autocmd.Callback
function M.on_very_lazy(cb) Autocmd.set1("User", cb, { pattern = "VeryLazy" }) end

---Checks whether the given module is present.
---@param mod string
function M.has_module(mod) return require("lazy.core.cache").find(mod) ~= nil end

---Loads a module.
---@generic T
---@param mod string
---@param ty? string
---@return T?
function M.load_module(mod, ty)
  local ok, ret = M.try(function()
    ---@diagnostic disable-next-line:missing-return
    if M.has_module(mod) then return require(mod) end
  end, ("Failed to load module '%s'"):format(mod))
  if not ok then return end
  if ty then
    if type(ret) == ty then return ret end
    Log.error("Module '%s' should return a '%s'", mod, ty)
  else
    return ret
  end
end

---Loads a module that returns a table.
---@param mod string
---@return table?
function M.load_table(mod) return M.load_module(mod, "table") end

---Loads a module that returns a function.
---@param mod string
---@return function?
function M.load_function(mod) return M.load_module(mod, "function") end

---Checks if a string starts with another.
---@param s string
---@param pat string
function M.starts_with(s, pat) return s:sub(1, #pat) == pat end

---Merge lists into a single list.
---Note: This mutates the first list.
---@generic T
---@param dst T[]
---@param ... T[]
function M.merge_lists(dst, ...)
  for _, val in ipairs({ ... }) do
    for _, t in ipairs(val) do
      table.insert(dst, t)
    end
  end
  return dst
end

---Merge tables into a signle table.
---Note: This mutates the first table.
---@generic T
---@param dst T
---@param ... T
---@return T
function M.merge_tables(dst, ...)
  for _, val in ipairs({ ... }) do
    for k, v in pairs(val) do
      if dst[k] == nil then dst[k] = v end
    end
  end
  return dst
end

return M
