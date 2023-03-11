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

---@alias DeltaVim.Keymap.With fun(src:DeltaVim.Keymap.Input):DeltaVim.CustomKeymap

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
---Variant name
---@field variant? string

---@alias DeltaVim.Keymaps DeltaVim.Keymap[]|DeltaVim.Keymap.Options

---@alias DeltaVim.Keymap DeltaVim.CustomKeymap|DeltaVim.PresetKeymap

---@class DeltaVim.CustomKeymap: DeltaVim.BaseKeymap
---Key
---@field [1] string
---Callback function or command
---@field [2] string|fun()

---@class DeltaVim.PresetKeymap: DeltaVim.BaseKeymap
---Key or boolean value to enable a preset
---@field [1] string|boolean
---Preset name starts with '@'
---@field [2] string
---@field variant? string

---@class DeltaVim.BaseKeymap: DeltaVim.Keymap.Options
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
---@field mode string[]
---@field desc? string
---@field variant? string

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
---@param preset DeltaVim.Keymap.Preset
---@param input DeltaVim.Keymap.Input
function Collector:_map_preset(preset, input)
  -- 1) Check if variant matches.
  if preset.variant ~= input.variant then return end
  -- 2) Select common modes.
  ---@type string[]
  local mode
  local pmode = preset.mode
  -- If no modes are specified, uses modes defined by the preset.
  if #input.mode == 0 then
    if not pmode or pmode == "*" then
      mode = { "n" }
    else
      mode = {}
      for _, m in ipairs(get_mode(pmode)) do
        table.insert(mode, m == "*" and "n" or m)
      end
    end
  -- If the preset supports all modes, then use input modes.
  elseif not pmode or pmode == "*" then
    mode = input.mode
  -- Otherwise, only common modes will be selected.
  else
    local supported = {} ---@type table<string,boolean>
    for _, m in ipairs(get_mode(pmode)) do
      supported[m] = true
    end
    if supported["*"] then
      mode = input.mode
    else
      mode = {}
      for _, m in ipairs(input.mode) do
        if supported[m] then table.insert(mode, m) end
      end
      if #mode == 0 then return end
    end
  end
  -- 3) Generate output.
  local opts = get_opts(preset, { desc = input.desc or preset[3] })
  if preset.with then
    local output = preset.with(input)
    self:add({
      output[1],
      output[2],
      mode = mode,
      opts = get_opts(output, opts),
    })
  else
    self:add({
      input[1] or preset.key,
      preset[2],
      mode = mode,
      opts = opts,
    })
  end
end

---Converts preset inputs to the output.
---@param presets DeltaVim.Keymap.Presets
function Collector:map(presets)
  local opts = get_opts(presets)
  for _, preset in ipairs(presets) do
    local name, variant = Util.split(preset[1], ":")
    preset = Util.merge({}, opts, { variant = variant }, preset)
    for _, input in ipairs(get(name) or {}) do
      self:_map_preset(preset, input)
    end
  end
  return self
end

---Similar as `Collector:map`, but more than one inputs will be ignored.
---@param presets DeltaVim.Keymap.Presets
function Collector:map_unique(presets)
  local opts = get_opts(presets)
  for _, preset in ipairs(presets) do
    local name, variant = Util.split(preset[1], ":")
    preset = Util.merge({}, opts, { variant = variant }, preset)
    local input = get(name)
    if input then
      if #input > 1 then
        Log.warn("Only the first key of '%s' will be set.", preset[1])
      end
      self:_map_preset(preset, input[1])
    end
  end
  return self
end

---Collects mappings from presets.
function Collector:collect()
  local ret = self._output
  self._output = {}
  return ret
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
        local r, v = Util.split(rhs, ":")
        add_input({
          ---@diagnostic disable-next-line:assign-type-mismatch
          k,
          r,
          mode = get_mode(mapping.mode or {}),
          desc = desc,
          variant = v or mapping.variant,
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
        vim.health.report_warn(("Keymap `%s` is not applied"):format(name))
      end
    end
  for k, v in pairs(INPUT) do
    cb(k, v.visited == true)
  end
end

M.Collector = Collector.new

return M
