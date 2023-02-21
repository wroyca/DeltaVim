-- Logger.

local M = {}

local LEVELS = vim.log.levels

local function factory(level)
  --- Log a message.
  ---@param msg string
  ---@param ... any
  return function(msg, ...) vim.notify(msg:format(...), level) end
end

M.error = factory(LEVELS.ERROR)
M.warn = factory(LEVELS.WARN)
M.debug = factory(LEVELS.DEBUG)

return M
