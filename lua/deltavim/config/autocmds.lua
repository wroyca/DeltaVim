local Autocmd = require("deltavim.core.autocmd")
local Util = require("deltavim.util")

local M = {}

M.QUIT = {
  "git",
  "help",
  "lspinfo",
  "man",
  "notify",
  "null-ls-info",
  "PlenaryTestPopup",
  "qf",
  "spectre_panel",
  "startuptime",
  "tsplayground",
  "TelescopePrompt",
  "vim",
}

M.RULERS = {
  lua = 80,
}

---@type DeltaVim.Autocmds
M.DEFAULT = {
  { "@auto_resize", true },
  { "@highlight_yank", true },
  { "@quit", true, ft = M.QUIT },
  { "@rulers", true, offsets = M.RULERS },
  { "@sync_time", true },
  { "@trim_spaces", true },
}

---@type DeltaVim.Autocmd.Collector
local CONFIG

function M.init()
  local cfg = Util.load_config("config.autocmds")
  if cfg == false then
    CONFIG = Autocmd.Collector()
  else
    CONFIG = Autocmd.load(Util.resolve_value(cfg or {}, M.DEFAULT, Util.concat))
  end
end

function M.setup()
  ---@type DeltaVim.Autocmd.Map
  local function quit(src)
    ---@class DeltaVim.Autocmds.Quit
    ---@field ft string[]
    local args = src.args
    local ft = Util.resolve_value(args.ft, M.QUIT, Util.concat)
    ---@type DeltaVim.Autocmd.Callback
    local function cb(ev)
      vim.bo[ev.buf].buflisted = false
      Util.keymap("n", "q", "<Cmd>close<CR>", { buffer = ev.buf })
    end
    return { "FileType", cb, pattern = ft }
  end

  ---@type DeltaVim.Autocmd.Map
  local function rulers(src)
    ---@class DeltaVim.Autocmds.Rulers
    ---@field offsets table<string,integer|integer[]>
    local args = src.args
    local offsets = Util.resolve_value(args.offsets, M.RULERS, Util.merge)
    local group = vim.api.nvim_create_augroup("DeltaVimRulers", {})
    ---@type DeltaVim.Autocmd[]
    local autocmds = {}
    for ft, offs in pairs(offsets) do
      ---@type string[]
      local cc = {}
      if type(offs) == "table" then
        for _, v in ipairs(offs) do
          table.insert(cc, tostring(v))
        end
      else
        table.insert(cc, tostring(offs))
      end
      ---@type DeltaVim.Autocmd.Callback

      table.insert(autocmds, {
        "FileType",
        function() vim.opt_local.colorcolumn = cc end,
        group = group,
        pattern = ft,
      })
    end
    return unpack(autocmds)
  end

  -- stylua: ignore
  ---@type DeltaVim.Autocmd.Presets
  local presets = {
    { "@auto_resize", "VimResized", "tabdo wincmd =" },
    { "@highlight_yank", "TextYankPost", function() vim.highlight.on_yank() end },
    { "@quit", with = quit },
    { "@rulers", with = rulers },
    { "@sync_time", { "FocusGained", "TermClose", "TermLeave" }, "checktime" },
    { "@trim_spaces", "BufWritePre", [[silent! s/\s+$//e]] },
  }
  CONFIG:map(presets):collect_and_set()
end

return M
