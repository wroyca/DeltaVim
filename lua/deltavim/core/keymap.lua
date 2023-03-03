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

---@alias DeltaVim.Keymap.With fun(src:DeltaVim.Keymap.Input):any

---@class DeltaVim.Keymap.Preset: DeltaVim.Keymap.Options
---Preset name
---@field [1] string
---Mapped value
---@field [2] any
---Description
---@field [3]? string
---@field mode? string|string[]
---@field with? DeltaVim.Keymap.With
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

---Collects and maps keymaps.
---@class DeltaVim.Keymap.Collector
---@field private _output DeltaVim.Keymap.Output[]
---table<name,table<mode,preset>>
---@field private _preset table<string,table<string,DeltaVim.Keymap.Preset>>
local Collector = {}

function Collector.new()
  local self = setmetatable({ _output = {} }, { __index = Collector })
  return self
end

---@param output DeltaVim.Keymap.Output
function Collector:add(output)
  table.insert(self._output, output)
  return self
end

---@private
---@param presets DeltaVim.Keymap.Presets
function Collector:_add_presets(presets)
  local opts = get_opts(presets, {})
  for _, preset in ipairs(presets) do
    preset = Util.merge({}, opts, preset)
    local name = preset[1]
    local mode = preset.mode
    if not self._preset[name] then self._preset[name] = {} end
    local p = self._preset[name]
    if not mode then
      p["*"] = preset
    else
      for _, m in ipairs(get_mode(mode)) do
        p[m] = preset
      end
    end
  end
end

---@private
---@param preset DeltaVim.Keymap.Preset
---@param input DeltaVim.Keymap.Input
---@param mode string
function Collector:_map_preset(preset, input, mode)
  local rhs = preset[2]
  if preset.with then rhs = preset.with(input) end
  local key = input[1] or preset.key
  if not key then return end
  self:add({
    key,
    rhs,
    -- TODO: string not string[]
    mode = { mode },
    opts = get_opts(preset, { desc = input.desc or preset[3] }),
  })
end

---@private
---@param input DeltaVim.Keymap.Input
function Collector:_do_map(input)
  local preset = self._preset[input[2]]
  -- If no modes are specified, uses modes defined by the preset.
  if #input.mode == 0 then
    for m, p in pairs(preset) do
      m = m == "*" and "n" or m
      self:_map_preset(p, input, m)
    end
  -- Otherwise, only supported modes will be mapped.
  else
    for _, m in ipairs(input.mode) do
      local p = preset[m] or preset["*"]
      if p then self:_map_preset(p, input, m) end
    end
  end
end

---Converts preset inputs to the output.
---@param presets DeltaVim.Keymap.Presets
function Collector:map(presets)
  self._preset = {}
  self:_add_presets(presets)
  for name, _ in pairs(self._preset) do
    for _, input in ipairs(get(name) or {}) do
      self:_do_map(input)
    end
  end
  return self
end

---Similar as `Collector:map`, but more than one inputs will be ignored.
---@param presets DeltaVim.Keymap.Presets
function Collector:map_unique(presets)
  self._preset = {}
  self:_add_presets(presets)
  for name, _ in pairs(self._preset) do
    local input = get(name)
    if input then
      if #input > 1 then
        Log.warn("Only the first key of '%s' will be set.", name)
      end
      self:_do_map(input[1])
    end
  end
  return self
end

---Collects mappings from presets.
function Collector:collect()
  self._output = {}
  for name, _ in pairs(self._preset) do
    for _, input in ipairs(get(name) or {}) do
      self:_do_map(input)
    end
  end
  return self._output
end

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
  local opts = get_opts(keymaps)
  for _, mapping in ipairs(keymaps) do
    ---@type DeltaVim.Keymap
    mapping = Util.merge({}, mapping, opts)
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
      collector:add({
        key,
        rhs,
        mode = get_mode(mapping.mode),
        opts = get_opts(mapping, { desc = desc }),
      })
    end
  end
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
