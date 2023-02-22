local Autocmd = require("deltavim.core.autocmd")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Autocmd[]
local CONFIG = {
  { "@auto_resize", true },
  { "@sync_time", true },
  { "@highlight_yank", true },
  { "@quit", true },
  { "@rulers", true, offsets = { lua = 80 } },
  { "@trim_spaces", true },
}

local did_load = false
function M.load()
  if not did_load then
    CONFIG = Util.merge_lists(CONFIG, Util.load_config("config.autocmds") or {})
  end
end

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
  return nil, autocmds
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
      { "@quit", quit },
      { "@rulers", rulers },
      {
        "@trim_spaces",
        "BufWritePre",
        [[silent! s/\s+$//e]],
      },
    })
    :collect_and_set()
end

return M
