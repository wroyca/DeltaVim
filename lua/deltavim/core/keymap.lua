local Util = require("deltavim.util")

-- Manage keymaps.

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

---@class DeltaVim.Keymap.Preset: DeltaVim.Keymap.Options
--- Preset name
---@field [1] string
--- Mapped value
---@field [2] any
--- Description
---@field [3]? string
---@field mode? string|string[]
---@field with? fun(src:DeltaVim.Keymap.Input):DeltaVim.Keymap ...

---@class DeltaVim.Keymap: DeltaVim.Keymap.Options
--- Key or boolean value to enable a preset
---@field [1] string|boolean
--- Callback function, command or a preset name starts with '@'
---@field [2] string|fun()
--- Description
---@field [3]? string
---@field mode? string|string[]

---@class DeltaVim.Keymap.Output
--- Key
---@field [1] string
--- Mapped value
---@field [2] any
---@field mode string[]
---@field opts DeltaVim.Keymap.Options

---@class DeltaVim.Keymap.Input
--- Key
---@field [1] string
--- Preset name
---@field [2] string
---@field mode string[]
---@field desc? string

local M = {}

---@type string[]
local DEFAULT_MODE = { "n" }
---@type table<string,{[1]:any}>
local DEFAULT_OPTS = {
  buffer = {},
  noremap = { true },
  remap = { false },
  nowait = {},
  silent = { true },
  script = {},
  expr = {},
  replace_keycodes = {},
  unique = {},
  desc = {},
}

--- Preset inputs shared by all collectors.
---@type table<string,DeltaVim.Keymap.Input[]>
local INPUT = {}

--- Collects modes.
---@param mode string|string[]|nil
---@param default? string[]
local function get_mode(mode, default)
  if type(mode) == "string" then
    mode = { mode }
  elseif type(mode) ~= "table" then
    mode = default or DEFAULT_MODE
  end
  return mode
end

--- Collects options.
---@param src DeltaVim.Keymap.Options
---@param init DeltaVim.Keymap.Options
local function get_opts(src, init)
  ---@type DeltaVim.Keymap.Options
  local opts = {}
  for k in pairs(DEFAULT_OPTS) do
    opts[k] = init[k] or src[k]
  end
  return opts
end

---@param mapping DeltaVim.Keymap.Input
local function add_input(mapping)
  local name = mapping[2]
  INPUT[name] = table.insert(INPUT[name] or {}, name)
end

---@param name string
local function remove_input(name) INPUT[name] = nil end

---@param collector DeltaVim.Keymap.Collector
---@param keymaps DeltaVim.Keymap[]
local function load_keymaps(collector, keymaps)
  for _, mapping in ipairs(keymaps) do
    local key = mapping[1]
    local rhs = mapping[2]
    local desc = mapping[3] or mapping.desc
    if type(rhs) == "string" and rhs:sub(1, 2) == "@" then
      if type(key) == "string" then
        add_input({
          key,
          rhs,
          mode = get_mode(mapping.mode, {}),
          desc = desc,
        })
      elseif key == false then
        remove_input(rhs)
      end
    elseif type(key) ~= "boolean" then
      collector:extend1({
        key,
        rhs,
        mode = get_mode(mapping.mode),
        opts = get_opts(mapping, { desc = desc }),
      })
    end
  end
end

--- Collects and maps keymaps.
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

--- Adds outputs which will be extended to the collected result.
---@param output DeltaVim.Keymap.Output[]
function Collector:extend(output)
  for _, m in ipairs(output) do
    self:extend1(m)
  end
  return self
end

---@param preset DeltaVim.Keymap.Preset
function Collector:map1(preset)
  for _, mapping in ipairs(INPUT[preset[1]] or {}) do
    if preset.with then
      load_keymaps(self, { preset.with(mapping) })
    elseif preset[2] then
      ---@type string[]
      local mode
      --- If no modes are specified, uses modes defined by the preset.
      if #mapping.mode == 0 then
        mode = get_mode(preset.mode)
      --- Otherwise, only supported modes will be mapped.
      else
        local supported = get_mode(preset.mode, {})
        -- Empty value means all modes are supported.
        if #supported == 0 then
          mode = mapping.mode
        -- Otherwise, finds common modes.
        else
          mode = {}
          for _, m in ipairs(mapping.mode) do
            if vim.tbl_contains(supported, m) then table.insert(mode, m) end
          end
          if #mode == 0 then return self end
        end
      end
      table.insert(self._output, {
        mapping[1],
        preset[2],
        mode = mode,
        opts = get_opts(preset, { desc = mapping.desc or preset[3] }),
      })
    end
  end
  return self
end

--- Converts preset inputs to the output.
---@param presets DeltaVim.Keymap.Preset[]
function Collector:map(presets)
  for _, preset in ipairs(presets) do
    self:map1(preset)
  end
  return self
end

--- Collects mappings from presets.
function Collector:collect() return self._output end

function Collector:collect_and_set() M.set(self:collect()) end

function Collector:collect_lazy()
  ---@type table[]
  local keymaps = {}
  for _, keymap in ipairs(self:collect()) do
    table.insert(
      keymaps,
      Util.merge_tables({
        keymap[1],
        keymap[2],
        mode = keymap.mode,
      }, keymap.opts)
    )
  end
  return keymaps
end

M.Collector = Collector.new

--- Loads keymaps. Preset inputs will be added to the global storage and other
--- keymaps will be extended into the returned collector.
---@param keymaps DeltaVim.Keymap[]
function M.load(keymaps)
  local collector = Collector.new()
  load_keymaps(collector, keymaps)
  return collector
end

local km = vim.keymap.set

--- Sets a keymap.
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param opts DeltaVim.Keymap.Options
function M.set1(mode, lhs, rhs, opts)
  local o = {}
  for k, v in pairs(DEFAULT_OPTS) do
    o[k] = opts[k] or v[1]
  end
  km(mode, lhs, rhs, o)
end

--- Sets keymaps.
---@param keymaps DeltaVim.Keymap.Output[]
function M.set(keymaps)
  for _, keymap in ipairs(keymaps) do
    M.set1(keymap.mode, keymap[1], keymap[2], keymap.opts)
  end
end

return M
