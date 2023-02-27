-- TODO: add plugin keymaps

local Config = require("deltavim.config")
local Log = require("deltavim.core.log")
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

---@type DeltaVim.Keymaps
local CONFIG

function M.init() CONFIG = Util.load_table("config.keymaps") or M.DEFAULT end

function M.setup()
  ---@type DeltaVim.Keymap.Map
  local function undo_break_point(src)
    local key = src[1]
    return { key, key .. "<C-g>u", mode = "i" }
  end

  ---@param opt string
  local function toggle_boolean(opt)
    vim.opt_local[opt] = not vim.opt_local[opt]:get()
  end

  ---@param opt string
  ---@param values? {[1]:any,[2]:any}
  local function toggle(opt, values)
    if not values then
      return function() toggle_boolean(opt) end
    else
      return function()
        if vim.opt_local[opt]:get() == values[1] then
          vim.opt_local[opt] = values[2]
        else
          vim.opt_local[opt] = values[1]
        end
      end
    end
  end

  local function toggle_autoformat()
    Config.lsp.autoformat = not Config.lsp.autoformat
  end

  local function toggle_line_number()
    toggle_boolean("relativenumber")
    toggle_boolean("number")
  end

  local toggle_conceallevel = toggle("conceallevel", { 0, vim.o.conceallevel })

  local enabled = true
  local function toggle_diagnostics()
    enabled = not enabled
    if enabled then
      vim.diagnostic.enable()
    else
      vim.diagnostic.disable()
    end
  end

  -- stylua: ignore
  ---@type DeltaVim.Keymap.Presets
  local presets = {
    -- Improve some keys.
    { "@enhanced.j", "v:count == 0 ? 'gj' : 'j'", key = "j", mode = "n", expr = true },
    { "@enhanced.k", "v:count == 0 ? 'gk' : 'k'", key = "k", mode = "n", expr = true },
    { "@enhanced.n", "'Nn'[v:searchforward]", "Next search", key = "n", mode = { "n", "x", "o" }, expr = true },
    { "@enhanced.N", "'nN'[v:searchforward]", "Prev search", key = "N", mode = { "n", "x", "o" }, expr = true },
    { "@enhanced.shl", "<gv", key = "<", mode = "x" },
    { "@enhanced.shr", ">gv", key = ">", mode = "x" },
    { "@enhanced.esc", "<Cmd>noh<CR><Esc>", key = "<Esc>", mode = { "n", "i" } },
    -- Move & split windows
    { "@window.move_down", "<C-w>j", "Goto down window" },
    { "@window.move_up", "<C-w>k", "Goto up window" },
    { "@window.move_left", "<C-w>h", "Goto left window" },
    { "@window.move_right", "<C-w>l", "Goto right window" },
    { "@window.increase_height", "<Cmd>vertical resize +2<CR>", "Increase window height" },
    { "@window.decrease_height", "<Cmd>vertical resize -2<CR>", "Decrease window height" },
    { "@window.increase_width", "<Cmd>resize +2<CR>", "Increase window width" },
    { "@window.decrease_width", "<Cmd>resize -2<CR>", "Decrease window width" },
    { "@window.switch_back", "<C-w>p", "Switch window back" },
    { "@window.close", "<C-w>c", "Close window" },
    { "@window.split", "<C-w>s", "Split window" },
    { "@window.vsplit", "<C-w>v", "Split window vertically" },
    -- Buffer
    { "@buffer.switch_back", "<Cmd>e #<CR>", "Switch buffer back" },
    -- Toggle UI/options
    { "@toggle.autoformat", toggle_autoformat, "Toggle autoformat" },
    { "@toggle.spell", toggle("spell"), "Toggle spelling" },
    { "@toggle.wrap", toggle("wrap"), "Toggle word wrap" },
    { "@toggle.line_number", toggle_line_number, "Toggle line number" },
    { "@toggle.diagnostics", toggle_diagnostics, "Toggle diagnostics" },
    { "@toggle.conceallevel", toggle_conceallevel, "Toggle conceallevel" },
    -- Tab
    { "@tab.next", "<Cmd>tabnext<CR>", "Next tab" },
    { "@tab.prev", "<Cmd>tabprevious<CR>", "Prev tab" },
    { "@tab.last", "<Cmd>tablast<CR>", "Last tab" },
    { "@tab.first", "<Cmd>tabfirst<CR>", "First tab" },
    { "@tab.new", "<Cmd>tabnew<CR>", "New tab" },
    { "@tab.close", "<Cmd>tabclose<CR>", "Close tab" },
    -- Util
    { "@util.save", "<Cmd>w<CR><Esc>", "Save file", mode = { "n", "i", "x" } },
    { "@util.new_file", "<Cmd>enew<CR>", "New file" },
    { "@util.search_this", "*N", "Search this word", mode = { "n", "x" } },
    { "@util.escape", "<Esc>", "Escape", mode = "i" },
    { "@util.undo_break_point", with = undo_break_point, },
    -- Move line up & down
    { "@util.move_line_down", "<Cmd>m .+1<CR>==", "Move line down", mode = "n" },
    { "@util.move_line_down", "<Cmd>m '>+1<CR>gv=gv", "Move line down", mode = "v" },
    { "@util.move_line_down", "<Esc><Cmd>m .+1<CR>==gi", "Move line down", mode = "i" },
    { "@util.move_line_up", "<Cmd>m .-2<CR>==", "Move line down", mode = "n" },
    { "@util.move_line_up", "<Cmd>m '>-2<CR>gv=gv", "Move line down", mode = "v" },
    { "@util.move_line_up", "<Esc><Cmd>m .-2<CR>==gi", "Move line down", mode = "i" },
    -- UI
    { "@ui.refresh", "<Cmd>noh<Bar>diffupdate<Bar>normal!<C-L><CR>", "Refresh" },
    { "@ui.lazy", "<Cmd>Lazy<CR>", "Lazy" },
    -- Session
    { "@session.quit", "<Cmd>qa<CR>", "Quit" },
  }
  -- Highlights under cursor
  if vim.fn.has("nvim-0.9.0") == 1 then
    table.insert(presets, { "@util.show_pos", vim.show_pos, "Show position" })
  end
  Keymap.load(CONFIG):map(presets):collect_and_set()
end

return M
