local Autocmd = require("deltavim.core.autocmd")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Autocmds
M.DEFAULT = {
  { "@checktime", true },
  { "@close_with_q", true },
  { "@highlight_yank", true },
  { "@resize_splits", true },
  { "@ruler", true },
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

  ---@param ev DeltaVim.Autocmd.Event
  local function trim_whitespace(ev)
    if vim.b[ev.buf]["deltavim.config.autocmds.trim_whitespace"] ~= false then
      vim.cmd([[s/\s\+$//e]])
    end
  end

  -- stylua: ignore
  CONFIG:map({
    { "@checktime", { "FocusGained", "TermClose", "TermLeave" }, "checktime" },
    { "@close_with_q", with = quit, args = quit_args },
    { "@highlight_yank", "TextYankPost", function() vim.highlight.on_yank() end },
    { "@resize_splits", "VimResized", "tabdo wincmd =" },
    { "@ruler", with = ruler, args = ruler_args },
    { "@trim_whitespace", "BufWritePre", trim_whitespace },
  }):collect_and_set()
end

return M
