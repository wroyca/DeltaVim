-- Manage auto commands.

---@class DeltaVim.Autocmd.Options
---@field group? string|integer
---@field buffer? integer
---@field pattern? string|string[]
---@field once? boolean
---@field nested? boolean
---@field desc? string

---@alias DeltaVim.Autocmd.Callback fun(args:DeltaVim.Autocmd.CallbackArgs)

---@class DeltaVim.Autocmd.CallbackArgs
---@field id number
---@field number string
---@field group? number
---@field match string
---@field buf number
---@field file string
---@field data any

---@class DeltaVim.Autocmd: DeltaVim.Autocmd.Options
--- Events
---@field [1] string|string[]
--- Command or callback function
---@field [2] string|DeltaVim.Autocmd.Callback
--- Description
---@field [3]? string

---@class DeltaVim.Autocmd.Source
--- Source name
---@field [1] string
---@field [2] fun(src:DeltaVim.Autocmd.Unmapped):DeltaVim.Autocmd.Mapped
--- Description
---@field [3]? string

---@class DeltaVim.Autocmd.Mapped
--- Events
---@field [1] string|string[]
--- Command or callback function
---@field [2] string|DeltaVim.Autocmd.Callback
---@field opts DeltaVim.Autocmd.Options

---@class DeltaVim.Autocmd.Unmapped
--- Events
---@field [1] string|string[]
--- Source name
---@field [2] string
---@field desc? string
---@field args table<string,any>

local M = {}

local DEFAULT_OPTS = {
  group = {},
  buffer = {},
  pattern = {},
  once = {},
  nested = {},
  desc = {},
}

--- Collects options and arguments.
---@param source table
---@param init DeltaVim.Autocmd.Options
local function get_opts(source, init)
  ---@type DeltaVim.Autocmd.Options
  local opts = {}
  for k, v in pairs(DEFAULT_OPTS) do
    opts[k] = init[k] == nil and (source[k] or v[1]) or init[k]
  end
  return opts
end

--- Collects arguments.
---@param source table
local function get_args(source)
  ---@type table<string,any>
  local args = {}
  for k, v in pairs(source) do
    if type(k) == "string" and DEFAULT_OPTS[k] == nil then args[k] = v end
  end
  return args
end

---@type table<string,DeltaVim.Autocmd.Unmapped>
local UNMAPPED = {}

---@class DeltaVim.Autocmd.Collector
---@field private _mapped DeltaVim.Autocmd.Mapped[]
local Collector = {}

function Collector.new()
  local self = setmetatable({ _mapped = {} }, { __index = Collector })
  return self
end

--- Adds a autocmd.
---@param autocmd DeltaVim.Autocmd.Mapped
function Collector:extend1(autocmd)
  table.insert(self._mapped, autocmd)
  return self
end

--- Adds many autocmds.
---@param autocmds DeltaVim.Autocmd.Mapped[]
function Collector:extend(autocmds)
  for _, autocmd in ipairs(autocmds) do
    self:extend1(autocmd)
  end
  return self
end

--- Maps a source.
---@param source DeltaVim.Autocmd.Source
function Collector:map1(source)
  local src = UNMAPPED[source[1]]
  if src ~= nil then
    local autocmd = source[2](src)
    local opts = autocmd.opts
    opts.desc = opts.desc or source[3]
    table.insert(self._mapped, autocmd)
  end
  return self
end

--- Maps many sources.
---@param sources DeltaVim.Autocmd.Source[]
function Collector:map(sources)
  for _, source in ipairs(sources) do
    self:map1(source)
  end
  return self
end

--- Collects mapped autocmds.
function Collector:collect() return self._mapped end

--- Adds an autocmd.
---@param autocmd DeltaVim.Autocmd.Unmapped
function M.extend1(autocmd)
  local name = autocmd[2]
  UNMAPPED[name] = autocmd
  return M
end

--- Adds many autocmds.
---@param autocmds DeltaVim.Autocmd.Unmapped[]
function M.extend(autocmds)
  for _, autocmd in ipairs(autocmds) do
    M.extend1(autocmd)
  end
  return M
end

--- Loads auto commands.
---@param autocmds DeltaVim.Autocmd[]
function M.load(autocmds)
  local collector = Collector.new()
  for _, autocmd in ipairs(autocmds) do
    local cmd = autocmd[2]
    local desc = autocmd[3] or autocmd.desc
    if type(cmd) == "string" and cmd:sub(1, 2) == "@" then
      M.extend1({
        autocmd[1],
        cmd,
        desc = desc,
        args = get_args(autocmd),
      })
    else
      collector:extend1({
        autocmd[1],
        cmd,
        opts = get_opts(autocmd, { desc = desc }),
      })
    end
  end
  return collector
end

return M
