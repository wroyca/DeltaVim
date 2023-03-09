-- Manage auto commands.

local Util = require("deltavim.util")

---@class DeltaVim.Autocmd.Options
---@field group? string|integer
---@field buffer? integer
---@field pattern? string|string[]
---@field once? boolean
---@field nested? boolean
---@field desc? string

---@alias DeltaVim.Autocmd.Callback fun(ev:DeltaVim.Autocmd.Event)

---@class DeltaVim.Autocmd.Event
---@field id number
---@field number string
---@field group? number
---@field match string
---@field buf number
---@field file string
---@field data any

---@alias DeltaVim.Autocmds DeltaVim.Autocmd[]|DeltaVim.Autocmd.Options

---@alias DeltaVim.Autocmd DeltaVim.CustomAutocmd|DeltaVim.PresetAutocmd

---@class DeltaVim.CustomAutocmd: DeltaVim.BaseAutocmd
---Events
---@field [1] string|string[]
---Command, callback function or boolean value to enable a preset
---@field [2] string|DeltaVim.Autocmd.Callback

---@class DeltaVim.PresetAutocmd: DeltaVim.BaseAutocmd
---Preset name starts with '@'
---@field [1] string
---Boolean value to enable a preset
---@field [2] boolean

---@class DeltaVim.BaseAutocmd: DeltaVim.Autocmd.Options
---Description
---@field [3]? string

---@alias DeltaVim.Autocmd.Presets DeltaVim.Autocmd.Preset[]|DeltaVim.Autocmd.Options

---@alias DeltaVim.Autocmd.With fun(src:DeltaVim.Autocmd.Input):DeltaVim.CustomAutocmd|DeltaVim.CustomAutocmd[]|{grouped?:boolean|string}

---@alias DeltaVim.Autocmd.Schema table<string,{[1]:DeltaVim.Util.Reduce,[2]:any}>

---@class DeltaVim.Autocmd.Preset: DeltaVim.Keymap.Options
---Preset name
---@field [1] string
---Events
---@field [2]? string|string[]
---Callback or command
---@field [3]? DeltaVim.Autocmd.Callback|string
---@field with? DeltaVim.Autocmd.With
---@field args? table<string,{[1]:DeltaVim.Util.Reduce,[2]:any}>
--
---@class DeltaVim.Autocmd.Output
---Events
---@field [1] string|string[]
---Command or callback function
---@field [2] string|DeltaVim.Autocmd.Callback
---@field opts DeltaVim.Autocmd.Options

---@alias DeltaVim.Autocmd.Inputs DeltaVim.Autocmd.Input[]|{visited?:boolean}

---@class DeltaVim.Autocmd.Input
---Preset name
---@field [1] string
---@field [2] boolean
---@field desc? string
---@field args table<string,any>

local M = {}

---Collects options and arguments.
---@param src table
---@param init? DeltaVim.Autocmd.Options
local function get_opts(src, init)
  ---@type DeltaVim.Autocmd.Options
  local opts = init or {}
  for k in pairs(Util.AUTOCMD_OPTS) do
    opts[k] = opts[k] or src[k]
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
---@type table<string,DeltaVim.Autocmd.Inputs>
local INPUT = {}

---@param preset string
---@return DeltaVim.Autocmd.Inputs?
local function get(preset)
  local ret = INPUT[preset]
  if ret then ret.visited = true end
  return ret
end

---@param input DeltaVim.Autocmd.Input
local function add_input(input)
  local name = input[1]
  if INPUT[name] == nil then INPUT[name] = {} end
  table.insert(INPUT[name], input)
end

---@param name string
local function remove_input(name) INPUT[name] = nil end

---@class DeltaVim.Autocmd.Collector
---@field private _output DeltaVim.Autocmd.Output[]
local Collector = {}

function Collector.new()
  local self = setmetatable({ _output = {} }, { __index = Collector })
  return self
end

---@param autocmd DeltaVim.Autocmd.Output
function Collector:add(autocmd)
  table.insert(self._output, autocmd)
  return self
end

---@private
---@param preset DeltaVim.Autocmd.Preset
function Collector:_map_preset(preset)
  local input = get(preset[1])
  if input == nil then return self end
  -- 1) Merge input tables.
  ---@type DeltaVim.Autocmd.Input
  local desc
  local args = {}
  ---@type DeltaVim.Autocmd.Schema
  local schema = preset.args or {}
  for k, v in pairs(schema) do
    args[k] = v[2]
  end
  for _, inp in ipairs(input) do
    desc = desc or inp.desc
    -- Reduce arguments
    local new = inp.args
    for k, t in pairs(schema) do
      if new[k] ~= nil then Util.reduce(t[1], args[k], new[k]) end
    end
  end
  -- 2) Collect output tables from custom function
  local src = { preset[1], desc = desc, args = args }
  if preset.with then
    local output = preset.with(src)
    if output.grouped then
      local group
      if type(output.grouped) == "string" then
        group = vim.api.nvim_create_augroup(output.grouped --[[@as string]], {})
      end
      ---@cast output DeltaVim.CustomAutocmd[]
      for _, o in ipairs(output) do
        self:add({
          o[1],
          o[2],
          opts = Util.merge({ group = group }, get_opts(o)),
        })
      end
    else
      ---@cast output DeltaVim.CustomAutocmd
      self:add({
        output[1],
        output[2],
        opts = get_opts(output),
      })
    end
  -- 3) Or construct from preset directly.
  elseif preset[2] then
    self:add({
      preset[2],
      preset[3],
      opts = get_opts(src),
    })
  end
  return self
end

---Constructs autocmds from preset inputs.
---@param presets DeltaVim.Autocmd.Presets
function Collector:map(presets)
  local opts = get_opts(presets)
  for _, preset in ipairs(presets) do
    self:_map_preset(Util.merge({}, preset, opts))
  end
  return self
end

---Collects output autocmds.
function Collector:collect()
  local ret = self._output
  self._output = {}
  return ret
end

function Collector:collect_and_set() M.set(self:collect()) end

---Loads auto commands.
---@param autocmds DeltaVim.Autocmds
function M.load(autocmds)
  local collector = Collector.new()
  local gopts = get_opts(autocmds)
  for _, autocmd in ipairs(autocmds) do
    autocmd = Util.merge({}, autocmd, gopts)
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
      collector:add({
        event,
        cmd,
        opts = get_opts(autocmd, { desc = desc }),
      })
    end
  end
  return collector
end

---Sets autocmds.
---@param autocmds DeltaVim.Autocmd.Output[]
function M.set(autocmds)
  for _, autocmd in ipairs(autocmds) do
    Util.autocmd(autocmd[1], autocmd[2], autocmd.opts)
  end
end

---@param cb? fun(name:string,visited:boolean)
function M.check(cb)
  cb = cb
    ---@param name string
    ---@param visited boolean
    or function(name, visited)
      if not visited then
        vim.health.report_warn(("Autocmd `%s` is not applied"):format(name))
      end
    end
  for k, v in pairs(INPUT) do
    cb(k, v.visited == true)
  end
end

M.Collector = Collector.new

return M
