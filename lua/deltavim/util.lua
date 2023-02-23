local LazyUtil = require("lazy.core.util")
local Log = require("deltavim.core.log")

local M = {
  try = LazyUtil.try,
}

---@generic T
---@param f fun():T
---@param opts? {msg?:string,on_error?:fun(err:any)}|string
---@return boolean, T|nil
function M.try(f, opts)
  if type(opts) == "string" then
    opts = { msg = opts }
  else
    opts = opts or {}
  end
  local msg = opts.msg or "An error occurs: %s"
  local on_error = opts.msg or function(err) Log.error(msg:format(err)) end
  local ok, ret = pcall(f)
  if ok then return true, ret end
  on_error(ret)
  return false
end

--- Checks whether the given module is present.
---@param mod string
function M.has_module(mod) return require("lazy.core.cache").find(mod) ~= nil end

--- Loads a module.
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

--- Loads a module that returns a table.
---@param mod string
---@return table?
function M.load_table(mod) return M.load_module(mod, "table") end

--- Loads a module that returns a function.
---@param mod string
---@return function?
function M.load_function(mod) return M.load_module(mod, "function") end

--- Merge lists into a signle list.
--- Note: This mutates the first table!
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

return M
