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

---@class DeltaVim.Keymap.Source: DeltaVim.Keymap.Options
--- Source name
---@field [1] string
--- Mapped value
---@field [2] any
--- Description
---@field [3]? string
---@field mode? string|string[]

---@class DeltaVim.Keymap: DeltaVim.Keymap.Options
--- Key or boolean value to enable a source
---@field [1] string|boolean
--- Callback function, command or source starts with '@'
---@field [2] string|fun()
--- Description
---@field [3]? string
---@field mode? string|string[]

---@class DeltaVim.Keymap.Mapped
--- Key
---@field [1] string
--- Mapped value
---@field [2] any
---@field mode string[]
---@field opts DeltaVim.Keymap.Options

---@class DeltaVim.Keymap.Unmapped
--- Key
---@field [1] string
--- Source name
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

--- Unmapped sources shared by all collectors.
---@type table<string,DeltaVim.Keymap.Unmapped[]>
local UNMAPPED = {}

--- Collects modes
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

--- Collects options
---@param source DeltaVim.Keymap.Options
---@param init DeltaVim.Keymap.Options
local function get_opts(source, init)
  ---@type DeltaVim.Keymap.Options
  local opts = {}
  for k in pairs(DEFAULT_OPTS) do
    opts[k] = init[k] or source[k]
  end
  return opts
end

--- Adds a mapping.
---@param mapping DeltaVim.Keymap.Unmapped
local function add(mapping)
  local source = mapping[2]
  UNMAPPED[source] = table.insert(UNMAPPED[source] or {}, source)
end

--- Removes a mapping.
---@param name string
local function remove(name) UNMAPPED[name] = nil end

---@param collector DeltaVim.Keymap.Collector
---@param keymaps DeltaVim.Keymap[]
local function load_keymaps(collector, keymaps)
  for _, mapping in ipairs(keymaps) do
    local key = mapping[1]
    local rhs = mapping[2]
    local desc = mapping[3] or mapping.desc
    if type(rhs) == "string" and rhs:sub(1, 2) == "@" then
      if type(key) == "string" then
        add({
          key,
          rhs,
          mode = get_mode(mapping.mode, {}),
          desc = desc,
        })
      elseif key == false then
        remove(rhs)
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
---@field private _mapped DeltaVim.Keymap.Mapped[]
local Collector = {}

function Collector.new()
  local self = setmetatable({ _mapped = {} }, { __index = Collector })
  return self
end

--- Adds a mapping.
---@param mapping DeltaVim.Keymap.Mapped
function Collector:extend1(mapping)
  table.insert(self._mapped, mapping)
  return self
end

--- Adds many mappings.
---@param mappings DeltaVim.Keymap.Mapped[]
function Collector:extend(mappings)
  for _, m in ipairs(mappings) do
    self:extend1(m)
  end
  return self
end

--- Maps a source.
---@param source DeltaVim.Keymap.Source
function Collector:map1(source)
  local name = source[1]
  for _, mapping in ipairs(UNMAPPED[name] or {}) do
    ---@type string[]
    local mode
    --- If no modes are specified, uses modes defined by the source.
    if #mapping.mode == 0 then
      mode = get_mode(source.mode)
    --- Otherwise, only supported modes will be mapped.
    else
      local supported = get_mode(source.mode, {})
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
    table.insert(self._mapped, {
      mapping[1],
      source[2],
      mode = mode,
      opts = get_opts(source, { desc = mapping.desc or source[3] }),
    })
  end
  return self
end

--- Adds many sources.
---@param sources DeltaVim.Keymap.Source[]
function Collector:map(sources)
  for _, source in ipairs(sources) do
    self:map1(source)
  end
  return self
end

--- Collects mappings from sources.
function Collector:collect() return self._mapped end

M.Collector = Collector.new

--- Loads keymaps.
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
---@param keymaps DeltaVim.Keymap.Mapped[]
function M.set(keymaps)
  for _, keymap in ipairs(keymaps) do
    M.set1(keymap.mode, keymap[1], keymap[2], keymap.opts)
  end
end

return M
