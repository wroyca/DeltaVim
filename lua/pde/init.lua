local M = {}

M.did_init = false
M.did_setup = false

M.config = require "pde.config"

local function lazy_notify()
  -- Based on notification lazy loading in LazyVim
  -- https://github.com/LazyVim/LazyVim/blob/a50f92f7550fb6e9f21c0852e6cb190e6fcd50f5/lua/lazyvim/util/init.lua#L90-L125
  local notifications = {}
  local function notify_queue(...) table.insert(notifications, vim.F.pack_len(...)) end
  local original_notify = vim.notify
  vim.notify = notify_queue

  local uv = vim.uv or vim.loop
  local timer, checker = assert(uv.new_timer()), assert(uv.new_check())

  local replay = function()
    timer:stop()
    checker:stop()
    if vim.notify == notify_queue then vim.notify = original_notify end
    vim.schedule(function()
      vim.tbl_map(function(notif) vim.notify(vim.F.unpack_len(notif)) end, notifications)
    end)
  end

  -- wait till vim.notify has been replaced
  checker:start(function()
    if vim.notify ~= notify_queue then replay() end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

function M.init()
  if vim.fn.has "nvim-0.9" == 0 then
    vim.api.nvim_echo({
      { "AstroNvim requires Neovim >= 0.9.0\n", "ErrorMsg" },
      { "Press any key to exit", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end

  if M.did_init then return end
  M.did_init = true

  lazy_notify()

  -- force setup during initialization
  local plugin = require("lazy.core.config").spec.plugins.pde
  M.setup(require("lazy.core.plugin").values(plugin, "opts"))
end

function M.setup(opts)
  if M.did_setup then return end

  opts = vim.tbl_deep_extend("force", M.config, opts)
  M.config = opts

  if not vim.g.mapleader and opts.mapleader then vim.g.mapleader = opts.mapleader end
  if not vim.g.maplocalleader and opts.maplocalleader then
    vim.g.maplocalleader = opts.maplocalleader
  end
  if opts.icons_enabled == false then vim.g.icons_enabled = false end
end

return M
