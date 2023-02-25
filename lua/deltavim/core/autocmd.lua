-- Manage auto commands.

local Util = require("deltavim.util")

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
---Events or a preset name starts with '@'
---@field [1] string|string[]
---Command, callback function or boolean value to enable a preset
---@field [2] string|DeltaVim.Autocmd.Callback|boolean
---Description
---@field [3]? string

---@class DeltaVim.Autocmd.Preset: DeltaVim.Keymap.Options
---Preset name
---@field [1] string
---Events or a function return a autocmd
---@field [2]? string|string[]
---Callback or command
---@field [3]? DeltaVim.Autocmd.Callback|string
---@field with? DeltaVim.Autocmd.Map

---@alias DeltaVim.Autocmd.Map fun(src:DeltaVim.Autocmd.Input):DeltaVim.Autocmd ...

---@class DeltaVim.Autocmd.Output
---Events
---@field [1] string|string[]
---Command or callback function
---@field [2] string|DeltaVim.Autocmd.Callback
---@field opts DeltaVim.Autocmd.Options

---@class DeltaVim.Autocmd.Input
---Preset name
---@field [1] string
---@field desc? string
---@field args table<string,any>

local M = {}

---Collects options and arguments.
---@param src table
---@param init DeltaVim.Autocmd.Options
local function get_opts(src, init)
  ---@type DeltaVim.Autocmd.Options
  local opts = {}
  for k in pairs(Util.AUTOCMD_OPTS) do
    opts[k] = init[k] or src[k]
  end
  return opts
end

---Collects arguments.
---@param src table
local function get_args(src)
  ---@type table<string,any>
  local args = {}
  for k, v in pairs(src) do
    if type(k) == "string" and Util.AUTOCMD_OPTS[k] == nil then args[k] = v end
  end
  return args
end

---Preset inputs shared by all collectors.
---@type table<string,DeltaVim.Autocmd.Input>
local INPUT = {}

---@param autocmd DeltaVim.Autocmd.Input
local function add_input(autocmd)
  local name = autocmd[2]
  INPUT[name] = autocmd
end

---@param name string
local function remove_input(name) INPUT[name] = nil end

---@param collector DeltaVim.Autocmd.Collector
---@param autocmds DeltaVim.Autocmd[]
local function load_autocmds(collector, autocmds)
  for _, autocmd in ipairs(autocmds) do
    local event = autocmd[1]
    local cmd = autocmd[2]
    local desc = autocmd[3] or autocmd.desc
    if type(event) == "string" and Util.starts_with(event, "@") then
      if cmd == true then
        add_input({
          event,
          desc = desc,
          args = get_args(autocmd),
        })
      elseif cmd == false then
        remove_input(event)
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
---@field private _output DeltaVim.Autocmd.Output[]
local Collector = {}

function Collector.new()
  local self = setmetatable({ _output = {} }, { __index = Collector })
  return self
end

---@param autocmd DeltaVim.Autocmd.Output
function Collector:extend1(autocmd)
  table.insert(self._output, autocmd)
  return self
end

---Adds autocmds.
---@param autocmds DeltaVim.Autocmd.Output[]
function Collector:extend(autocmds)
  for _, autocmd in ipairs(autocmds) do
    self:extend1(autocmd)
  end
  return self
end

---@param preset DeltaVim.Autocmd.Preset
function Collector:map1(preset)
  local src = INPUT[preset[1]]
  if src == nil then return self end
  if preset.with then
    load_autocmds(self, { preset.with(src) })
  elseif preset[2] then
    table.insert(self._output, {
      preset[2],
      preset[3],
      opts = get_opts(src, {}),
    })
  end
  return self
end

---Constructs autocmds from preset inputs.
---@param presets DeltaVim.Autocmd.Preset[]
function Collector:map(presets)
  for _, preset in ipairs(presets) do
    self:map1(preset)
  end
  return self
end

---Collects output autocmds.
function Collector:collect() return self._output end

function Collector:collect_and_set() M.set(self:collect()) end

---Loads auto commands.
---@param autocmds DeltaVim.Autocmd[]
function M.load(autocmds)
  local collector = Collector.new()
  load_autocmds(collector, autocmds)
  return collector
end

---Sets autocmds.
---@param autocmds DeltaVim.Autocmd.Output[]
function M.set(autocmds)
  for _, autocmd in ipairs(autocmds) do
    Util.autocmd(autocmd[1], autocmd[2], autocmd.opts)
  end
end

M.Collector = Collector.new

return M
