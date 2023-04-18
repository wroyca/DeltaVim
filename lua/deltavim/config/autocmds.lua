local Autocmd = require("deltavim.core.autocmd")
local Utils = require("deltavim.utils")

local M = {}

---@type DeltaVim.Autocmds
M.DEFAULT = {
  { "@auto_create_dir", true },
  { "@checktime", true },
  {
    "@close_with_q",
    ft = {
      "checkhealth",
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
  { "@highlight_yank", true },
  { "@last_loc", true },
  { "@resize_splits", true },
  { "@rulers", ft = { lua = 80 } },
  { "@spell", ft = { "gitcommit", "markdown" } },
  { "@trim_whitespace", true },
  { "@wrap", ft = { "gitcommit", "markdown" } },
}

---@type DeltaVim.Autocmd.Collector
local CONFIG

function M.init()
  CONFIG = Autocmd.load(
    Utils.reduce(
      "list",
      {},
      M.DEFAULT,
      Utils.load_config("custom.autocmds") or {}
    )
  )
end

function M.setup()
  ---@type DeltaVim.Autocmd.Callback
  local function auto_create_dir(ev)
    if ev.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end

  ---@class DeltaVim.Autocmds.CloseWithQ
  ---@field ft string[]
  ---@type DeltaVim.Autocmd.Schema
  local close_with_q_args = { ft = "list" }

  ---@type DeltaVim.Autocmd.With
  local function close_with_q(src)
    ---@type DeltaVim.Autocmd.Callback
    local function cb(ev)
      vim.bo[ev.buf].buflisted = false
      Utils.keymap("n", "q", "<Cmd>close<CR>", { buffer = ev.buf })
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

  ---@class DeltaVim.Autocmds.Ruler
  ---@field ft table<string,integer|integer[]>
  ---@type DeltaVim.Autocmd.Schema
  local rulers_args = { ft = "map" }

  ---@type DeltaVim.Autocmd.With
  local function rulers(src)
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

  ---@class DeltaVim.Autocmds.Spell
  ---@field ft table<string,boolean>
  ---@type DeltaVim.Autocmd.Schema
  local spell_args = { ft = "list" }

  ---@type DeltaVim.Autocmd.With
  local function spell(src)
    ---@type DeltaVim.Autocmd.Callback
    local function cb() vim.opt_local.spell = true end
    return { "FileType", cb, pattern = src.args.ft }
  end

  ---@param ev DeltaVim.Autocmd.Event
  local function trim_whitespace(ev)
    if vim.b[ev.buf]["deltavim.config.autocmds.trim_whitespace"] ~= false then
      vim.cmd([[s/\s\+$//e]])
    end
  end

  ---@class DeltaVim.Autocmds.Wrap
  ---@field ft table<string,boolean>
  ---@type DeltaVim.Autocmd.Schema
  local wrap_args = { ft = "list" }

  ---@type DeltaVim.Autocmd.With
  local function wrap(src)
    ---@type DeltaVim.Autocmd.Callback
    local function cb() vim.opt_local.wrap = true end
    return { "FileType", cb, pattern = src.args.ft }
  end

  -- stylua: ignore
  CONFIG:map({
    { "@auto_create_dir", "BufWritePre", auto_create_dir },
    { "@checktime", { "FocusGained", "TermClose", "TermLeave" }, "checktime" },
    { "@close_with_q", with = close_with_q, args = close_with_q_args },
    { "@highlight_yank", "TextYankPost", function() vim.highlight.on_yank() end },
    { "@last_loc", "BufReadPost", last_loc  },
    { "@resize_splits", "VimResized", "tabdo wincmd =" },
    { "@rulers", with = rulers, args = rulers_args },
    { "@spell", with = spell, args = spell_args },
    { "@trim_whitespace", "BufWritePre", trim_whitespace },
    { "@wrap", with = wrap, args = wrap_args },
  }):collect_and_set()
end

return M
