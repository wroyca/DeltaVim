-- Helpers to create keymaps/autocmds.

local Util = require("deltavim.util")

local M = {}

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
    return function()
      telescope(cmd, opts())
    end
  else
    return function()
      telescope(cmd, opts)
    end
  end
end

---Modified: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
---@param opts? table
local function telescope_files(opts)
  opts = Util.merge({}, opts or { cwd = Util.get_cwd() })
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
    return function()
      telescope_files(opts())
    end
  else
    return function()
      telescope_files(opts)
    end
  end
end

function M.telescope_search_current(opts)
  return function()
    if type(opts) == "function" then
      opts = opts()
    end
    local line = require("telescope.actions.state").get_current_line()
    telescope_files(Util.merge({ default_text = line }, opts))
  end
end

---@param mode string
---@param opts? table
local function trouble(mode, opts)
  opts = Util.merge({ mode = mode }, opts or {})
  require("trouble").toggle(opts)
end

---Creates a function that toggles trouble.nvim with given options.
---@param mode string
---@param opts? table|fun():table
function M.trouble(mode, opts)
  if type(opts) == "function" then
    return function()
      trouble(mode, opts())
    end
  else
    return function()
      trouble(mode, opts)
    end
  end
end

---@param force? boolean
function M.bufremove(force)
  return function(n)
    require("mini.bufremove").delete(n or 0, force)
  end
end

return M
