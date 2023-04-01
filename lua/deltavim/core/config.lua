local Autocmds = require("deltavim.config.autocmds")
local Config = require("deltavim.config")
local Log = require("deltavim.core.log")
local Keymaps = require("deltavim.config.keymaps")
local Options = require("deltavim.config.options")
local Utils = require("deltavim.utils")

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
  Utils.lazy_notify()

  -- Initialize configs
  Autocmds.init()
  Keymaps.init()
  Options.init()

  -- Load options before installing plugins
  Options.setup()
  fix_lazy()
end

function M.setup()
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
    Utils.on_very_lazy(setup)
  else
    setup()
  end

  Utils.try(function()
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

return M
