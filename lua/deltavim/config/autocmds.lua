local Autocmd = require("deltavim.core.autocmd")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Autocmds
M.DEFAULT = {
  { "@auto_resize", true },
  { "@highlight_yank", true },
  { "@quit", true },
  { "@ruler", true },
  { "@sync_time", true },
  { "@trim_whitespace", true },
}

---@type DeltaVim.Autocmd.Collector
local CONFIG

function M.init()
  local cfg = Util.load_config("config.autocmds")
  if cfg == false then
    CONFIG = Autocmd.Collector()
  else
    CONFIG = Autocmd.load(Util.reduce("list", {}, M.DEFAULT, cfg or {}))
  end
end

function M.setup()
  ---@class DeltaVim.Autocmds.Quit
  ---@field ft string[]
  ---@type DeltaVim.Autocmd.Schema
  local quit_args = {
    ft = {
      "list",
      {
        "git",
        "help",
        "lspinfo",
        "man",
        "notify",
        "null-ls-info",
        "PlenaryTestPopup",
        "qf",
        "query",
        "spectre_panel",
        "startuptime",
        "tsplayground",
        "TelescopePrompt",
        "vim",
      },
    },
  }

  ---@class DeltaVim.Autocmds.Rulers
  ---@field ft table<string,integer|integer[]>
  ---@type DeltaVim.Autocmd.Schema
  local ruler_args = {
    ft = {
      "map",
      { lua = 80 },
    },
  }

  ---@type DeltaVim.Autocmd.With
  local function quit(src)
    ---@type DeltaVim.Autocmd.Callback
    local function cb(ev)
      vim.bo[ev.buf].buflisted = false
      Util.keymap("n", "q", "<Cmd>close<CR>", { buffer = ev.buf })
    end
    return { "FileType", cb, pattern = src.args.ft }
  end

  ---@type DeltaVim.Autocmd.With
  local function ruler(src)
    ---@type DeltaVim.Autocmd[]
    local autocmds = {}
    for ft, offs in pairs(src.args.ft) do
      ---@type string[]
      local cc = {}
      if type(offs) == "table" then
        for _, v in ipairs(offs) do
          table.insert(cc, tostring(v))
        end
      else
        table.insert(cc, tostring(offs))
      end
      table.insert(autocmds, {
        "FileType",
        function() vim.opt_local.colorcolumn = cc end,
        pattern = ft,
      })
    end
    autocmds.grouped = "DeltaVimRulers"
    return autocmds
  end

  -- stylua: ignore
  CONFIG:map({
    { "@auto_resize", "VimResized", "tabdo wincmd =" },
    { "@highlight_yank", "TextYankPost", function() vim.highlight.on_yank() end },
    { "@quit", with = quit, args = quit_args },
    { "@ruler", with = ruler, args = ruler_args },
    { "@sync_time", { "FocusGained", "TermClose", "TermLeave" }, "checktime" },
    { "@trim_whitespace", "BufWritePre", [[silent! s/\s\+$//e]] },
  }):collect_and_set()
end

return M
