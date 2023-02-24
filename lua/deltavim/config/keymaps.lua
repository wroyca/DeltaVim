-- TODO: add plugin keymaps

local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Keymap[]
M.DEFAULT = {
  { true, "@enhanced.j" },
  { true, "@enhanced.k" },
  { true, "@enhanced.n" },
  { true, "@enhanced.N" },
  { true, "@enhanced.shl" },
  { true, "@enhanced.shr" },
  { true, "@enhanced.esc" },
}

---@type DeltaVim.Keymap[]
local CONFIG

function M.init() CONFIG = Util.load_table("config.keymaps") or M.DEFAULT end

function M.setup()
  Keymap.load(CONFIG)
    :map({
      -- Improve some keys.
      {
        "@enhanced.j",
        "v:count == 0 ? 'gj' : 'j'",
        key = "j",
        mode = "n",
        expr = true,
      },
      {
        "@enhanced.k",
        "v:count == 0 ? 'gk' : 'k'",
        key = "k",
        mode = "n",
        expr = true,
      },
      {
        "@enhanced.n",
        "'Nn'[v:searchforward]",
        "Next search",
        key = "n",
        mode = { "n", "x", "o" },
        expr = true,
      },
      {
        "@enhanced.N",
        "'nN'[v:searchforward]",
        "Prev search",
        key = "N",
        mode = { "n", "x", "o" },
        expr = true,
      },
      { "@enhanced.shl", "<gv", key = "<", mode = "x" },
      { "@enhanced.shr", ">gv", key = ">", mode = "x" },
      {
        "@enhanced.esc",
        "<Cmd>noh<CR><Esc>",
        key = "<Esc>",
        mode = { "i", "n" },
      },
      -- Move & split windows
      { "@window.move_down", "<C-w>j", "Goto down window" },
      { "@window.move_up", "<C-w>k", "Goto up window" },
      { "@window.move_left", "<C-w>h", "Goto left window" },
      { "@window.move_right", "<C-w>l", "Goto right window" },
      { "@window.split", "C-w>s", "Split window" },
      { "@window.vsilit", "<C-w>v", "Split window vertically" },
      {
        "@window.increase_height",
        "<Cmd>vertical resize +2<CR>",
        "Increase window height",
      },
      {
        "@window.decrease_height",
        "<Cmd>vertical resize -2<CR>",
        "Decrease window height",
      },
      {
        "@window.increase_width",
        "<Cmd>resize +2<CR>",
        "Increase window width",
      },
      {
        "@window.decrease_width",
        "<Cmd>resize -2<CR>",
        "Decrease window width",
      },
      -- Tab
      { "@tab.next", "<Cmd>tabnext<CR>", "Next tab" },
      { "@tab.prev", "<Cmd>tabprevious<CR>", "Prev tab" },
      { "@tab.last", "<Cmd>tablast<CR>", "Last tab" },
      { "@tab.first", "<Cmd>tabfirst<CR>", "First tab" },
      { "@tab.new", "<Cmd>tabnew<CR>", "New tab" },
      { "@tab.close", "<Cmd>tabclose<CR>", "Close tab" },
      -- Util
      {
        "@util.new_file",
        "<Cmd>enew<CR>",
        "New file",
      },
      {
        "@util.search_this",
        "*N",
        "Search this word",
        mode = { "n", "x" },
      },
      {
        "@util.escape",
        "<Esc>",
        "Escape",
        mode = "i",
      },
      {
        "@util.save",
        "<Cmd>w<CR><Esc>",
        "Save file",
        mode = { "n", "i", "v" },
      },
      -- Move line up & down
      {
        "@util.move_line_down",
        "<Cmd>m .+1<CR>==",
        "Move line down",
        mode = "n",
      },
      {
        "@util.move_line_down",
        "<Cmd>m '>+1<CR>gv=gv",
        "Move line down",
        mode = "v",
      },
      {
        "@util.move_line_down",
        "<Esc><Cmd>m .+1<CR>==gi",
        "Move line down",
        mode = "i",
      },
      {
        "@util.move_line_up",
        "<Cmd>m .-2<CR>==",
        "Move line down",
        mode = "n",
      },
      {
        "@util.move_line_up",
        "<Cmd>m '>-2<CR>gv=gv",
        "Move line down",
        mode = "v",
      },
      {
        "@util.move_line_up",
        "<Esc><Cmd>m .-2<CR>==gi",
        "Move line down",
        mode = "i",
      },
      -- UI
      {
        "@ui.refresh",
        "<Cmd>noh<Bar>diffupdate<Bar>normal!<C-L><CR>",
        "Refresh",
      },
      -- Show lazy UI
      { "@show.lazy", "<Cmd>Lazy<CR>", "Lazy" },
      -- Buffer
      { "@buffer.switch_back", "<Cmd>e #<CR>", "Switch buffer back" },
      -- Session
      { "@session.quit", "<Cmd>qa<CR>", "Quit" },
    })
    :collect_and_set()
end

return M
