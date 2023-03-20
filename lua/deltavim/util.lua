local Log = require("deltavim.core.log")

local M = {}

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

---@param key string
---@param mode? string
function M.feedkey(key, mode)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(key, true, false, true),
    mode or "n",
    false
  )
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
---@param cb fun(client:any,buffer:integer)
function M.on_lsp_attach(cb)
  M.autocmd(
    "LspAttach",
    function(ev) cb(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf) end
  )
end

---Checks whether the given module is present.
---@param mod string
function M.has_module(mod)
  local info = require("lazy.core.cache").find(mod)
  return info ~= nil and #info > 0
end

---Loads a module.
---@param mod string
---@return any
function M.load_module(mod)
  local _, ret = M.try(function()
    ---@diagnostic disable-next-line:missing-return
    if M.has_module(mod) then return require(mod) end
  end, ("Failed to load module '%s'"):format(mod))
  return ret
end

---Loads a config module that returns an optional table or function.
---@param mod string
---@return table|function|false?
function M.load_config(mod)
  local ret = M.load_module(mod)
  if type(ret) == "table" or type(ret) == "function" then
    return ret
  elseif ret == true then
    return
  elseif ret == false then
    return false
  else
    Log.error("Module '%s' should return a function or table", mod)
  end
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

---@param tbl table
function M.is_list(tbl)
  local i = 1
  for _ in pairs(tbl) do
    if tbl[i] == nil then return false end
    i = i + 1
  end
  return true
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
---@generic K
---@param tbl table<K,any>
---@return table<K,any>
function M.copy_as_table(tbl)
  local ret = {}
  for k, v in pairs(tbl) do
    if v == true then
      ret[k] = {}
    elseif v then
      ret[k] = v
    end
  end
  return ret
end

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

---@param cmd string|{[1]:string,[2]?:string}
---@param opts? table
local function telescope(cmd, opts)
  if type(cmd) == "table" then
    require("telescope").extensions[cmd[1]][cmd[2] or cmd[1]](opts)
  else
    require("telescope.builtin")[cmd](opts)
  end
end

---Creates a function that opens telescope.nvim with given command.
---@param cmd string|{[1]:string,[2]?:string}
---@param opts? table|fun():table
function M.telescope(cmd, opts)
  if type(opts) == "function" then
    return function() telescope(cmd, opts()) end
  else
    return function() telescope(cmd, opts) end
  end
end

---Modified: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
---@param opts? table
local function telescope_files(opts)
  opts = M.merge({}, opts or { cwd = M.get_cwd() })
  local cmd = "find_files"
  if vim.loop.fs_stat(opts.cwd .. "/.git") then
    opts.show_untracked = true
    cmd = "git_files"
  end
  require("telescope.builtin")[cmd](opts)
end

---Open `git_files` or `find_files` depending on `.git`.
---@param opts? table|fun():table
function M.telescope_files(opts)
  if type(opts) == "function" then
    return function() telescope_files(opts()) end
  else
    return function() telescope_files(opts) end
  end
end

---@param mode string
---@param opts? table
local function trouble(mode, opts)
  opts = M.merge({ mode = mode }, opts or {})
  require("trouble").toggle(opts)
end

---Creates a function that toggles trouble.nvim with given options.
---@param mode string
---@param opts? table|fun():table
function M.trouble(mode, opts)
  if type(opts) == "function" then
    return function() trouble(mode, opts()) end
  else
    return function() trouble(mode, opts) end
  end
end

---@param force? boolean
function M.bufremove(force)
  return function(n) require("mini.bufremove").delete(n or 0, force) end
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

---Delay notifications till vim.notify was replaced.
---Modified: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
---@param timeout? number
function M.lazy_notify(timeout)
  timeout = timeout or 500
  ---@type table[]
  local notifications = {}
  local function temp(...) table.insert(notifications, vim.F.pack_len(...)) end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer() --[[@as uv.uv_timer_t]]
  local check = vim.loop.new_check() --[[@as uv.uv_check_t]]

  local replay = function()
    timer:stop()
    check:stop()
    -- Put back the original notify if needed
    if vim.notify == temp then vim.notify = orig end
    vim.schedule(function()
      for _, args in ipairs(notifications) do
        vim.notify(vim.F.unpack_len(args))
      end
    end)
  end

  -- Wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then replay() end
  end)
  -- Or if it reached timeout, then something went wrong
  timer:start(timeout, 0, replay)
end

---@alias DeltaVim.Util.Reduce "list"|"map"|"table"|"string"|"number"|"boolean"

---Merges values into a single value.
---Note: this mutates the dst.
---@generic T
---@param f fun(dst:T,new:T):T
---@param ... T|fun(val:T):T
function M.reduce_with(f, dst, ...)
  for _, val in ipairs({ ... }) do
    if type(val) == "function" then
      dst = val(dst)
    else
      dst = f(dst, val)
    end
  end
  return dst
end

local function override(_, new) return new end

---@generic T
---@param ty DeltaVim.Util.Reduce
---@param dst T
---@param ... T|fun(val:T):T
function M.reduce(ty, dst, ...)
  local f
  if ty == "list" then
    f = M.concat
  elseif ty == "map" then
    f = M.merge
  elseif ty == "table" then
    f = M.deep_merge
  else
    f = override
  end
  return M.reduce_with(f, dst, ...)
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

return M
