local Autocmds = require("deltavim.config.autocmds")
local Config = require("deltavim.config")
local Log = require("deltavim.core.log")
local Keymaps = require("deltavim.config.keymaps")
local Options = require("deltavim.config.options")
local Util = require("deltavim.util")

local M = {}

M.lazy_version = ">=9.1.0"

---LazyVim may have overwritten options of the Lazy ui, use this to reset.
local function fix_lazy()
  if vim.bo.filetype == "lazy" then vim.cmd.doautocmd("VimResized") end
end

local did_init = false
function M.init()
  if did_init then return end
  did_init = true

  -- Delay notifications
  M.lazy_notify()

  -- Initialize configs
  Autocmds.init()
  Keymaps.init()
  Options.init()

  -- Load options before installing plugins
  Options.setup()
  fix_lazy()
end

---@param opts DeltaVim.Config?
function M.setup(opts)
  Config.update(opts or {})

  if not M.check_version() then
    Log.error(
      "**DeltaVim** needs **lazy.nvim** version %s to work properly.",
      M.lazy_version
    )
    error("Exiting")
  end

  local function setup()
    Autocmds.setup()
    Keymaps.setup()
    fix_lazy()
  end

  if vim.fn.argc(-1) == 0 then
    Util.on_very_lazy(setup)
  else
    setup()
  end

  Util.try(function()
    local colorscheme = Config.colorscheme
    if type(colorscheme) == "function" then
      colorscheme()
    else
      vim.cmd.colorscheme(colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function() vim.cmd.colorscheme("habamax") end,
  })
end

---@param ver? string
function M.check_version(ver)
  return require("lazy.manage.semver")
    .range(ver or M.lazy_version)
    :matches(require("lazy.core.config").version or "0.0.0")
end

---Delay notifications till vim.notify was replaced.
---Modified: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/init.lua
---@param timeout? number
function M.lazy_notify(timeout)
  timeout = timeout or 1000
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

return M
