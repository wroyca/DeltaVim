local Autocmd = require("deltavim.core.autocmd")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

---@alias DeltaVim.Autocmds DeltaVim.Autocmd[]

local M = {}

---@type DeltaVim.Autocmd[]
M.DEFAULT = {
  { "@auto_resize", true },
  { "@sync_time", true },
  { "@highlight_yank", true },
  { "@quit", true },
  { "@rulers", true, offsets = { lua = 80 } },
  { "@trim_spaces", true },
}

---@type DeltaVim.Autocmd[]
local CONFIG

function M.init() CONFIG = Util.load_table("config.autocmds") or M.DEFAULT end

---@type DeltaVim.Autocmd.Map
local function quit(src)
  ---@class DeltaVim.Autocmds.Quit
  ---@field ft string[]
  local args = src.args
  ---@type DeltaVim.Autocmd.Callback
  local function cb(ev)
    vim.bo[ev.buf].buflisted = false
    Keymap.set1("n", "q", "<Cmd>close<CR>", { buffer = ev.buf })
  end
  return { "FileType", cb }
end

---@type DeltaVim.Autocmd.Map
local function rulers(src)
  ---@class DeltaVim.Autocmds.Rulers
  ---@field offsets table<string,integer|integer[]>
  local args = src.args
  local group = vim.api.nvim_create_augroup("DeltaVimRulers", {})
  ---@type DeltaVim.Autocmd[]
  local autocmds = {}
  for ft, offsets in pairs(args.offsets) do
    ---@type string[]
    local cc = {}
    if type(offsets) == "table" then
      for _, v in ipairs(offsets) do
        table.insert(cc, tostring(v))
      end
    else
      table.insert(cc, tostring(offsets))
    end
    ---@type DeltaVim.Autocmd.Callback
    local function cb(ev) vim.bo[ev.buf].colorcolumn = cc end
    table.insert(autocmds, { "FileType", cb, group = group, pattern = ft })
  end
  return unpack(autocmds)
end

function M.setup()
  Autocmd.load(CONFIG)
    :map({
      {
        "@auto_resize",
        "VimResized",
        "tabdo wincmd =",
      },
      {
        "@sync_time",
        { "FocusGained", "TermClose", "TermLeave" },
        "checktime",
      },
      {
        "@highlight_yank",
        "TextYankPost",
        function() vim.highlight.on_yank() end,
      },
      { "@quit", with = quit },
      { "@rulers", with = rulers },
      {
        "@trim_spaces",
        "BufWritePre",
        [[silent! s/\s+$//e]],
      },
    })
    :collect_and_set()
end

return M
