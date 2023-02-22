-- TODO: use `preset` instead of `source`

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
--- Events or source starts with '@'
---@field [1] string|string[]
--- Command, callback function or boolean value to enable a source
---@field [2] string|DeltaVim.Autocmd.Callback|boolean
--- Description
---@field [3]? string

---@class DeltaVim.Autocmd.Source: DeltaVim.Keymap.Options
--- Source name
---@field [1] string
--- Events or a function return a autocmd
---@field [2] string|string[]|DeltaVim.Autocmd.Map
--- Callback or command
---@field [3]? DeltaVim.Autocmd.Callback|string

---@alias DeltaVim.Autocmd.Map fun(src:DeltaVim.Autocmd.Unmapped):DeltaVim.Autocmd?,DeltaVim.Autocmd.Mapped[]?

---@class DeltaVim.Autocmd.Mapped
--- Events
---@field [1] string|string[]
--- Command or callback function
---@field [2] string|DeltaVim.Autocmd.Callback
---@field opts DeltaVim.Autocmd.Options

---@class DeltaVim.Autocmd.Unmapped
--- Source name
---@field [1] string
---@field desc? string
---@field args table<string,any>

local M = {}

---@type table<string,{[1]:any}>
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
  for k in pairs(DEFAULT_OPTS) do
    opts[k] = init[k] or source[k]
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

--- Adds an autocmd.
---@param autocmd DeltaVim.Autocmd.Unmapped
local function add(autocmd)
  local name = autocmd[2]
  UNMAPPED[name] = autocmd
end

--- Removes a source.
---@param name string
local function remove(name) UNMAPPED[name] = nil end

---@param collector DeltaVim.Autocmd.Collector
---@param autocmds DeltaVim.Autocmd[]
local function load_autocmds(collector, autocmds)
  for _, autocmd in ipairs(autocmds) do
    local event = autocmd[1]
    local cmd = autocmd[2]
    local desc = autocmd[3] or autocmd.desc
    if type(event) == "string" and event:sub(1, 2) == "@" then
      if cmd == true then
        add({
          event,
          desc = desc,
          args = get_args(autocmd),
        })
      elseif cmd == false then
        remove(event)
      end
    elseif type(cmd) ~= "boolean" then
      collector:extend1({
        event,
        cmd,
        opts = get_opts(autocmd, { desc = desc }),
      })
    end
  end
end

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
  if src == nil then return self end
  local f = source[2]
  ---@type DeltaVim.Autocmd.Mapped
  local autocmd
  if type(f) == "function" then
    local r1, r2 = f(src)
    local autocmds = r2 or {}
    if r1 ~= nil then table.insert(autocmds, r1) end
    load_autocmds(self, autocmds)
  else
    autocmd = {
      f,
      source[3],
      opts = get_opts(src, {}),
    }
  end
  table.insert(self._mapped, autocmd)
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

--- Loads auto commands.
---@param autocmds DeltaVim.Autocmd[]
function M.load(autocmds)
  local collector = Collector.new()
  load_autocmds(collector, autocmds)
  return collector
end

local au = vim.api.nvim_create_autocmd

--- Sets a autocmd.
---@param events string|string[]
---@param cmd string|DeltaVim.Autocmd.Callback
---@param opts DeltaVim.Autocmd.Options
function M.set1(events, cmd, opts)
  local o = {}
  if type(cmd) == "string" then
    o.command = cmd
  else
    o.callback = cmd
  end
  for k, v in pairs(DEFAULT_OPTS) do
    o[k] = opts[k] or v[1]
  end
  au(events, o)
end

--- Sets autocmds.
---@param autocmds DeltaVim.Autocmd.Mapped[]
function M.set(autocmds)
  for _, autocmd in ipairs(autocmds) do
    M.set1(autocmd[1], autocmd[2], autocmd.opts)
  end
end

M.Collector = Collector.new

return M
