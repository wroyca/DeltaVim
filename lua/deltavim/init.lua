local M = {}

M.did_init = false
M.did_setup = false
M.config = require "deltavim.config"

---Returns certain border configuration with specified highlight.
---@param border string the config key, can be `popup_border` or `float_border`
---@param hl string? the highlight to be used
---@return table
function M.get_border(border, hl)
  hl = hl or "NormalFloat"
  return vim.tbl_map(function(v) return { v, hl } end, M.config[border] --[[@as table]])
end

function M.init()
  if vim.fn.has "nvim-0.9" == 0 then
    vim.api.nvim_echo({
      { "DeltaVim requires Neovim >= 0.9.0\n", "ErrorMsg" },
      { "Press any key to exit", "MoreMsg" },
    }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end

  -- TODO: remove these hacks after NeoVim v0.9
  vim.uv = vim.uv or vim.loop
  vim.ui.open = vim.ui.open or function(...) require("astrocore").system_open(...) end

  if M.did_init then return end
  M.did_init = true

  local notify = require "deltavim.notify"
  notify.setup()
  notify.defer_startup()

  -- force setup during initialization
  local plugin = require("lazy.core.config").spec.plugins["DeltaVim"]
  M.setup(require("lazy.core.plugin").values(plugin, "opts"))
end

function M.setup(opts)
  if M.did_setup then return end
  opts = require("deltavim.utils").deep_merge(M.config, opts)

  if not vim.g.mapleader and opts.mapleader then vim.g.mapleader = opts.mapleader end
  if not vim.g.maplocalleader and opts.maplocalleader then
    vim.g.maplocalleader = opts.maplocalleader
  end
  if opts.icons_enabled == false then vim.g.icons_enabled = false end
end

return M
