local Log = require("deltavim.core.log")

local M = {}

M.ROOT_PATTERNS = { ".git" }

---Returns the root directory based on:
---* lsp workspace folders
---* lsp root_dir
---* root pattern of filename of the current buffer
---* root pattern of cwd
---Modified: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
---@return string
function M.get_root()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace
          and vim.tbl_map(
            function(ws) return vim.uri_to_fname(ws.uri) end,
            workspace
          )
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if r and path:find(r, 1, true) then roots[#roots + 1] = r end
      end
    end
  end
  table.sort(roots, function(a, b) return #a > #b end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or M.get_cwd()
    ---@type string?
    root = vim.fs.find(M.ROOT_PATTERNS, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or M.get_cwd()
  end
  ---@cast root string
  return root
end

---@return string
function M.get_cwd()
  return vim.loop.cwd() --[[@as string]]
end

---@type string[]
M.KEYMAP_MODE = { "n" }

---@type table<string,{[1]:any}>
M.KEYMAP_OPTS = {
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

---Sets a keymap.
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param opts? DeltaVim.Keymap.Options
function M.keymap(mode, lhs, rhs, opts)
  opts = opts or {}
  local o = {}
  for k, v in pairs(M.KEYMAP_OPTS) do
    o[k] = opts[k] or v[1]
  end
  vim.keymap.set(mode, lhs, rhs, o)
end

---@type table<string,{[1]:any}>
M.AUTOCMD_OPTS = {
  group = {},
  buffer = {},
  pattern = {},
  once = {},
  nested = {},
  desc = {},
}

---Sets a autocmd.
---@param events string|string[]
---@param cmd string|DeltaVim.Autocmd.Callback
---@param opts? DeltaVim.Autocmd.Options
function M.autocmd(events, cmd, opts)
  opts = opts or {}
  local o = {}
  if type(cmd) == "string" then
    o.command = cmd
  else
    o.callback = cmd
  end
  for k, v in pairs(M.AUTOCMD_OPTS) do
    o[k] = opts[k] or v[1]
  end
  vim.api.nvim_create_autocmd(events, o)
end

---@generic T
---@param f fun():T?
---@param opts? {msg?:string,on_error?:fun(err:any)}|string
---@return boolean, T|nil
function M.try(f, opts)
  if type(opts) == "string" then
    opts = { msg = opts }
  else
    opts = opts or { msg = "An error occurs: %s" }
  end
  local msg = opts.msg
  local on_error = opts.on_error
  local ok, ret = pcall(f)
  if ok then return true, ret end
  if msg then Log.error(msg, ret) end
  if on_error then on_error(ret) end
  return false
end

---Registers a callback on the VeryLazy event.
---@param cb fun(buffer:integer)
function M.on_very_lazy(cb)
  M.autocmd("User", function(ev) cb(ev.buf) end, { pattern = "VeryLazy" })
end

---Registers a callback on the LspAttach event.
---@param cb fun(client:table,buffer:integer)
function M.on_lsp_attach(cb)
  M.autocmd(
    "LspAttach",
    function(ev) cb(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf) end
  )
end

---@param plugin string
function M.has(plugin)
  local plug = require("lazy.core.config").plugins[plugin]
  if not plug then return false end
  if type(plug.cond) == "function" then
    return plug.cond() ~= false
  else
    return plug.cond ~= false
  end
end

---Checks whether the given module is present.
---@param mod string
function M.has_module(mod)
  local info = require("lazy.core.cache").find(mod)
  return info ~= nil and #info > 0
end

---Loads a config module that returns an optional table or function.
---@param mod string
---@return (table|fun(dst:table):table|nil|boolean)?
function M.load_config(mod)
  local _, ret = M.try(function()
    if M.has_module(mod) then return require(mod) end
  end, ("Failed to load module '%s'"):format(mod))
  if
    type(ret) == "table"
    or type(ret) == "function"
    or type(ret) == "boolean"
  then
    return ret
  elseif ret ~= nil then
    Log.error("Module '%s' should return a function/table/boolean", mod)
  end
end

---@param key string
---@param mode? string
function M.feedkey(key, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(key, true, false, true),
    mode or "n",
    false
  )
end

---Checks if a string starts with another.
---@param s string
---@param pat string
function M.starts_with(s, pat) return s:sub(1, #pat) == pat end

---Splits a string
---@param s string
---@param pat string
---@return string,string?
function M.split(s, pat)
  local i, j = s:find(pat, nil, true)
  if i ~= nil then
    return s:sub(1, i - 1), s:sub(j + 1)
  else
    return s
  end
end

---Merge lists into a single list.
---Note: This mutates the first list.
---@generic T
---@param dst T[]
---@param ... T[]
function M.concat(dst, ...)
  for _, val in ipairs({ ... }) do
    for _, t in ipairs(val) do
      table.insert(dst, t)
    end
  end
  return dst
end

---Merge tables into a signle table.
---Note: This mutates the first table.
---@generic T: table
---@param dst T
---@param ... T
---@return T
function M.merge(dst, ...)
  for _, val in ipairs({ ... }) do
    for k, v in pairs(val) do
      if v == vim.NIL then
        dst[k] = nil
      else
        dst[k] = v
      end
    end
  end
  return dst
end

---Returns whether given table is a list.
---Note: An empty table is not considered as a list.
---@param tbl table
function M.is_list(tbl)
  local i = 1
  for _ in pairs(tbl) do
    if tbl[i] == nil then return false end
    i = i + 1
  end
  return i > 1
end

local function is_table(t) return type(t) == "table" and not M.is_list(t) end

---@generic T: table
---@param dst T
local function deep_merge(dst, tbl)
  for k, v in pairs(tbl) do
    if is_table(dst[k]) and is_table(v) then
      deep_merge(dst[k], v)
    elseif v == vim.NIL then
      dst[k] = nil
    else
      dst[k] = v
    end
  end
end

---Recursively merge tables into a signle table.
---Note: This mutates the first table.
---@generic T: table
---@param dst T
---@param ... T
---@return T
function M.deep_merge(dst, ...)
  for _, val in ipairs({ ... }) do
    deep_merge(dst, val)
  end
  return dst
end

---Constructs a table from the given table, `false` values will be removed and
---`true` values will be replaced with empty tables.
---@param tbl table<string,table|boolean>
function M.copy_as_table(tbl)
  ---@type table<string,table>
  local ret = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      ret[k] = v
    elseif v then
      ret[k] = {}
    end
  end
  return ret
end

---@param list string[]
function M.list_to_set(list)
  ---@type table<string,boolean>
  local set = {}
  for _, k in ipairs(list) do
    set[k] = true
  end
  return set
end

---@alias DeltaVim.Utils.ReduceType "list"|"map"|"table"
---@alias DeltaVim.Utils.Reducer table|(fun(dst:table):table)|boolean|nil

---Merges values into a single value.
---Note: this mutates the dst.
---@param f fun(dst:table,new:table):table
---@param dst table
---@param ... DeltaVim.Utils.Reducer
---@return table
function M.reduce_with(f, dst, ...)
  for _, val in ipairs({ ... }) do
    if type(val) == "function" then
      dst = val(dst)
    elseif type(val) == "table" then
      dst = f(dst, val)
    elseif val == false then
      dst = {}
    end
  end
  return dst
end

---@param ty DeltaVim.Utils.ReduceType
---@param dst table
---@param ... DeltaVim.Utils.Reducer
function M.reduce(ty, dst, ...)
  local f
  if ty == "list" then
    f = M.concat
  elseif ty == "map" then
    f = M.merge
  else
    f = M.deep_merge
  end
  return M.reduce_with(f, dst, ...)
end

return M
