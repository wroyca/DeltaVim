-- Manage keymaps.

local Log = require("deltavim.core.log")
local Util = require("deltavim.util")

---@class DeltaVim.Keymap.Options
---@field buffer? integer
---@field noremap? boolean
---@field remap? boolean
---@field nowait? boolean
---@field silent? boolean
---@field script? boolean
---@field expr? boolean
---@field replace_keycodes? boolean
---@field unique? boolean
---@field desc? string

---@alias DeltaVim.Keymap.Presets DeltaVim.Keymap.Preset[]|DeltaVim.Keymap.Options

---@alias DeltaVim.Keymap.Map fun(src:DeltaVim.Keymap.Input):DeltaVim.Keymap? ...

---@class DeltaVim.Keymap.Preset: DeltaVim.Keymap.Options
---Preset name
---@field [1] string
---Mapped value
---@field [2] any
---Description
---@field [3]? string
---@field mode? string|string[]
---@field with? DeltaVim.Keymap.Map
---Default key to be set
---@field key? string

---@alias DeltaVim.Keymaps DeltaVim.Keymap[]|DeltaVim.Keymap.Options

---@class DeltaVim.Keymap: DeltaVim.Keymap.Options
---Key or boolean value to enable a preset
---@field [1] string|boolean
---Callback function, command or a preset name starts with '@'
---@field [2] string|fun()
---Description
---@field [3]? string
---@field mode? string|string[]

---@class DeltaVim.Keymap.Output
---Key
---@field [1] string
---Mapped value
---@field [2] any
---@field mode string[]
---@field opts DeltaVim.Keymap.Options

---@alias DeltaVim.Keymap.Inputs DeltaVim.Keymap.Input[]|{visited?:boolean}

---@class DeltaVim.Keymap.Input
---Key
---@field [1]? string
---Preset name
---@field [2] string
---@field args table<string,any>
---@field mode string[]
---@field desc? string

local M = {}

---Preset inputs shared by all collectors.
---@type table<string,DeltaVim.Keymap.Inputs>
local INPUT = {}

---@param preset string
---@return DeltaVim.Keymap.Inputs?
local function get(preset)
  local ret = INPUT[preset]
  if ret then ret.visited = true end
  return ret
end

---Collects modes.
---@param mode string|string[]|nil
local function get_mode(mode)
  if type(mode) == "string" then
    return { mode }
  else
    return mode or Util.KEYMAP_MODE
  end
end

---Collects options.
---@param src table
---@param init? DeltaVim.Keymap.Options
local function get_opts(src, init)
  ---@type DeltaVim.Keymap.Options
  local opts = init or {}
  for k in pairs(Util.KEYMAP_OPTS) do
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
    if type(k) == "string" and Util.KEYMAP_OPTS[k] == nil then args[k] = v end
  end
  return args
end

---@param mapping DeltaVim.Keymap.Input
local function add_input(mapping)
  local name = mapping[2]
  if not INPUT[name] then INPUT[name] = {} end
  table.insert(INPUT[name], mapping)
end

---@param name string
local function remove_input(name) INPUT[name] = nil end

---@param collector DeltaVim.Keymap.Collector
---@param keymaps DeltaVim.Keymaps
local function load_keymaps(collector, keymaps)
  local gopts = get_opts(keymaps)
  for _, mapping in ipairs(keymaps) do
    ---@type DeltaVim.Keymap
    mapping = Util.merge({}, mapping, gopts)
    local key = mapping[1]
    local rhs = mapping[2]
    local desc = mapping[3] or mapping.desc
    if type(rhs) == "string" and Util.starts_with(rhs, "@") then
      if key == false then
        remove_input(rhs)
      else
        ---@type string?
        local k
        if key == true then
          k = nil
        else
          k = key --[[@as string]]
        end
        add_input({
          ---@diagnostic disable-next-line:assign-type-mismatch
          k,
          rhs,
          args = get_args(mapping),
          mode = get_mode(mapping.mode or {}),
          desc = desc,
        })
      end
    elseif type(key) == "string" then
      collector:extend1({
        key,
        rhs,
        mode = get_mode(mapping.mode),
        opts = get_opts(mapping, { desc = desc }),
      })
    end
  end
end

---Collects and maps keymaps.
---@class DeltaVim.Keymap.Collector
---@field private _output DeltaVim.Keymap.Output[]
local Collector = {}

function Collector.new()
  local self = setmetatable({ _output = {} }, { __index = Collector })
  return self
end

---@param output DeltaVim.Keymap.Output
function Collector:extend1(output)
  table.insert(self._output, output)
  return self
end

---Adds outputs which will be extended to the collected result.
---@param output DeltaVim.Keymap.Output[]
function Collector:extend(output)
  for _, m in ipairs(output) do
    self:extend1(m)
  end
  return self
end

---@private
---@param preset DeltaVim.Keymap.Preset
---@param input DeltaVim.Keymap.Input
function Collector:_map_preset(preset, input)
  if preset.with then
    load_keymaps(self, { preset.with(input) })
  else
    local key = input[1] or preset.key
    if key == nil then return end
    ---@type string[]
    local mode
    ---If no modes are specified, uses modes defined by the preset.
    if #input.mode == 0 then
      mode = get_mode(preset.mode)
    ---Otherwise, only supported modes will be mapped.
    else
      -- Empty value means all modes are supported.
      if not preset.mode then
        mode = input.mode
      -- Otherwise, finds common modes.
      else
        local supported = {}
        for _, m in ipairs(get_mode(preset.mode or {})) do
          supported[m] = true
        end
        mode = {}
        for _, m in ipairs(input.mode) do
          if supported[m] then table.insert(mode, m) end
        end
        if #mode == 0 then return end
      end
    end
    table.insert(self._output, {
      key,
      preset[2],
      mode = mode,
      opts = get_opts(preset, { desc = input.desc or preset[3] }),
    })
  end
end

---@param preset DeltaVim.Keymap.Preset
function Collector:map1(preset)
  for _, input in ipairs(get(preset[1]) or {}) do
    self:_map_preset(preset, input)
  end
  return self
end

---Converts preset inputs to the output.
---@param presets DeltaVim.Keymap.Presets
function Collector:map(presets)
  local gopts = get_opts(presets)
  for _, preset in ipairs(presets) do
    self:map1(Util.merge({}, preset, gopts))
  end
  return self
end

---@param preset DeltaVim.Keymap.Preset
function Collector:map1_unique(preset)
  local inputs = get(preset[1]) or {}
  if #inputs >= 1 then
    if #inputs > 1 then
      Log.warn("Only the first key of '%s' will be set.", preset[1])
    end
    self:_map_preset(preset, inputs[1])
  end
  return self
end

---Similar as `Collector:map`, but more than one inputs will be ignored.
---@param presets DeltaVim.Keymap.Presets
function Collector:map_unique(presets)
  local gopts = get_opts(presets)
  for _, preset in ipairs(presets) do
    self:map1_unique(Util.merge({}, preset, gopts))
  end
  return self
end

---Collects mappings from presets.
function Collector:collect() return self._output end

---@param opts? DeltaVim.Keymap.Options
function Collector:collect_and_set(opts) M.set(self:collect(), opts) end

---Constructs a list of tables that could be used as keys of `lazy.nvim`.
---@param init? table[]
function Collector:collect_lazy(init)
  local keymaps = init or {}
  for _, keymap in ipairs(self:collect()) do
    table.insert(
      keymaps,
      Util.merge({
        keymap[1],
        keymap[2],
        mode = keymap.mode,
      }, keymap.opts)
    )
  end
  return keymaps
end

---Constructs a table of mapped values indexed by the input keys.
---@param init? table<string,any>
function Collector:collect_lhs_table(init)
  local tbl = init or {}
  for _, keymap in ipairs(self:collect()) do
    tbl[keymap[1]] = keymap[2]
  end
  return tbl
end

---Constructs a table of input keys indexed by mapped values.
---@param init? table<any,string>
function Collector:collect_rhs_table(init)
  local tbl = init or {}
  for _, keymap in ipairs(self:collect()) do
    tbl[keymap[2]] = keymap[1]
  end
  return tbl
end

M.Collector = Collector.new

---Loads keymaps. Preset inputs will be added to the global storage and other
---keymaps will be extended into the returned collector.
---@param keymaps DeltaVim.Keymaps
function M.load(keymaps)
  local collector = Collector.new()
  load_keymaps(collector, keymaps)
  return collector
end

---Sets keymaps.
---@param keymaps DeltaVim.Keymap.Output[]
---@param opts? DeltaVim.Keymap.Options
function M.set(keymaps, opts)
  for _, keymap in ipairs(keymaps) do
    Util.keymap(
      keymap.mode,
      keymap[1],
      keymap[2],
      Util.merge({}, opts or {}, keymap.opts)
    )
  end
end

---@param cb? fun(name:string,visited:boolean)
function M.check(cb)
  cb = cb
    ---@param name string
    ---@param visited boolean
    or function(name, visited)
      if not visited then
        vim.health.report_warn(("Keymap `%s` is not mapped"):format(name))
      end
    end
  for k, v in pairs(INPUT) do
    cb(k, v.visited == true)
  end
end

return M
