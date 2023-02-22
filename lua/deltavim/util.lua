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
---@param mod string
---@return boolean, any
function M.load_module(mod)
  return M.try(function()
    ---@diagnostic disable-next-line:missing-return
    if M.has_module(mod) then return require(mod) end
  end, ("Failed to load module '%s'"):format(mod))
end

--- Loads a config module.
---@return table?
function M.load_config(mod)
  local ok, config = M.load_module(mod)
  if not ok then return end
  if type(config) == "table" then return config end
  Log.error("Module '%s' should return a table", mod)
end

--- Merge lists into a signle list.
---@generic T
---@param list T[]
---@param ... T[]
function M.merge_lists(list, ...)
  for _, val in ipairs({ ... }) do
    for _, t in ipairs(val) do
      table.insert(list, t)
    end
  end
  return list
end

return M
