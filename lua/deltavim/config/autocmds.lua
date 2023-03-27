local Autocmd = require("deltavim.core.autocmd")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Autocmds
M.DEFAULT = {
  { "@checktime", true },
  { "@close_with_q", true },
  { "@highlight_yank", true },
  { "@last_loc", true },
  { "@resize_splits", true },
  { "@ruler", true },
  { "@trim_whitespace", true },
  { "@wrap_spell", true },
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
  ---@class DeltaVim.Autocmds.CloseWithQ
  ---@field ft string[]
  ---@type DeltaVim.Autocmd.Schema
  local close_with_q_args = {
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

  ---@type DeltaVim.Autocmd.With
  local function close_with_q(src)
    ---@type DeltaVim.Autocmd.Callback
    local function cb(ev)
      vim.bo[ev.buf].buflisted = false
      Util.keymap("n", "q", "<Cmd>close<CR>", { buffer = ev.buf })
    end
    return { "FileType", cb, pattern = src.args.ft }
  end

  local function last_loc()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end

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

  ---@class DeltaVim.Autocmds.WrapSpell
  ---@field ft table<string,boolean>
  ---@type DeltaVim.Autocmd.Schema
  local wrap_spell_args = {
    ft = {
      "list",
      { "gitcommit", "markdown" },
    },
  }

  ---@type DeltaVim.Autocmd.With
  local function wrap_spell(src)
    ---@type DeltaVim.Autocmd.Callback
    local function cb()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end
    return { "FileType", cb, pattern = src.args.ft }
  end

  -- stylua: ignore
  CONFIG:map({
    { "@checktime", { "FocusGained", "TermClose", "TermLeave" }, "checktime" },
    { "@close_with_q", with = close_with_q, args = close_with_q_args },
    { "@highlight_yank", "TextYankPost", function() vim.highlight.on_yank() end },
    { "@last_loc", "BufReadPost", last_loc  },
    { "@resize_splits", "VimResized", "tabdo wincmd =" },
    { "@ruler", with = ruler, args = ruler_args },
    { "@trim_whitespace", "BufWritePre", trim_whitespace },
    { "@wrap_spell", with = wrap_spell, args = wrap_spell_args },
  }):collect_and_set()
end

return M
