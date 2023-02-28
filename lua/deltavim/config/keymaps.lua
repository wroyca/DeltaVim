local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Keymaps
M.DEFAULT = {
  -- enhanced
  { true, "@enhanced.j" },
  { true, "@enhanced.k" },
  { true, "@enhanced.n" },
  { true, "@enhanced.N" },
  { true, "@enhanced.shl" },
  { true, "@enhanced.shr" },
  { true, "@enhanced.esc" },
  -- window
  { "<C-h>", "@window.move_left" },
  { "<C-j>", "@window.move_down" },
  { "<C-k>", "@window.move_up" },
  { "<C-l>", "@window.move_right" },
  { "<C-Up>", "@window.increase_height" },
  { "<C-Down>", "@window.decrease_height" },
  { "<C-Left>", "@window.decrease_width" },
  { "<C-Right>", "@window.increase_width" },
  { "<Leader>ww", "@window.switch_back" },
  { "<Leader>wd", "@window.close" },
  { "<Leader>w-", "@window.split" },
  { "<Leader>w|", "@window.vsplit" },
  { "<Leader>-", "@window.split" },
  { "<Leader>|", "@window.vsplit" },
  -- ui
  { "<Leader>ur", "@ui.refresh" },
  { "<Leader>l", "@ui.lazy" },
  { "<Leader>ui", "@util.show_pos" },
  { "<Leader>uC", "@search.colorschemes" },
  -- toggle
  { "<Leader>uf", "@toggle.autoformat" },
  { "<Leader>us", "@toggle.spell" },
  { "<Leader>uw", "@toggle.wrap" },
  { "<Leader>ul", "@toggle.line_number" },
  { "<Leader>ud", "@toggle.diagnostics" },
  { "<Leader>uc", "@toggle.conceallevel" },
  -- tab
  { "<Leader><Tab>l", "@tab.last" },
  { "<Leader><Tab>f", "@tab.first" },
  { "<Leader><Tab><Tab>", "@tab.new" },
  { "<Leader><Tab>d", "@tab.close" },
  { "<Leader><Tab>]", "@tab.next" },
  { "<Leader><Tab>[", "@tab.prev" },
  -- cmp/snippet
  { "<Tab>", "@snippet.next_node" },
  { "<S-Tab>", "@snippet.prev_node" },
  { "<Down>", "@cmp.next_item" },
  { "<Up>", "@cmp.prev_item" },
  { "<C-y>", "@cmp.confirm" },
  { "<C-n>", "@cmp.next_item" },
  { "<C-p>", "@cmp.prev_item" },
  { "<C-b>", "@cmp.scroll_up" },
  { "<C-f>", "@cmp.scroll_down" },
  { "<C-Space>", "@cmp.complete" },
  { "<C-e>", "@cmp.abort" },
  { "<CR>", "@cmp.confirm" },
  -- surround
  { "gza", "@surround.add" },
  { "gzd", "@surround.delete" },
  { "gzf", "@surround.find" },
  { "gzF", "@surround.find_left" },
  { "gzh", "@surround.highlight" },
  { "gzr", "@surround.replace" },
  { "gzn", "@surround.update_n_lines" },
  -- comment
  { "gc", "@comment.toggle" },
  { "gcc", "@comment.toggle_line" },
  { "<Leader>fe", "@explorer.toggle" },
  { "<Leader>fE", "@explorer.toggle_cwd" },
  { "<Leader>e", "@explorer.toggle" },
  { "<Leader>E", "@explorer.toggle_cwd" },
  -- file/find
  { "<Leader><Leader>", "@search.files" },
  { "<Leader>fn", "@util.new_file" },
  { "<Leader>fb", "@search.buffers" },
  { "<Leader>ff", "@search.files" },
  { "<Leader>fF", "@search.files_cwd" },
  { "<Leader>fr", "@search.oldfiles" },
  -- terminal
  { "<C-t>", "@terminal.open" },
  { "<C-t>", "@terminal.hide" },
  { "<Leader>ft", "@terminal.open" },
  { "<Leader>fT", "@terminal.open_cwd" },
  -- search
  { "<Leader>,", "@search.buffers_all" },
  { "<Leader>:", "@search.command_history" },
  { "<Leader>sr", "@search.replace" },
  { "<Leader>sa", "@search.autocommands" },
  { "<Leader>sb", "@search.current_buffer" },
  { "<Leader>sc", "@search.command_history" },
  { "<Leader>sC", "@search.commands" },
  { "<Leader>sd", "@search.workspace_diagnostics" },
  { "<Leader>sg", "@search.grep" },
  { "<Leader>sG", "@search.grep_cwd" },
  { "<Leader>sh", "@search.help_tags" },
  { "<Leader>sH", "@search.highlights" },
  { "<Leader>sk", "@search.keymaps" },
  { "<Leader>sm", "@search.marks" },
  { "<Leader>sM", "@search.man_pages" },
  { "<Leader>so", "@search.options" },
  { "<Leader>sR", "@search.resume" },
  { "<Leader>sw", "@search.words" },
  { "<Leader>sW", "@search.words_cwd" },
  -- git
  { "]h", "@goto.next_hunk" },
  { "[h", "@goto.prev_hunk" },
  { "ih", "@select.hunk" },
  { "<Leader>gg", "@terminal.lazygit" },
  { "<Leader>gG", "@terminal.lazygit_cwd" },
  { "<Leader>gc", "@search.git_commits" },
  { "<Leader>gs", "@search.git_status" },
  -- hunk
  { "<Leader>ghs", "@git.stage_hunk" },
  { "<Leader>ghr", "@git.reset_hunk" },
  { "<Leader>ghS", "@git.stage_buffer" },
  { "<Leader>ghR", "@git.reset_buffer" },
  { "<Leader>ghu", "@git.undo_stage_hunk" },
  { "<Leader>ghp", "@git.preview_hunk" },
  { "<Leader>ghb", "@git.blame_line_full" },
  { "<Leader>ghd", "@git.diffthis" },
  { "<Leader>ghD", "@git.diffthis_last" },
  -- goto
  { "[[", "@goto.prev_reference" },
  { "]]", "@goto.next_reference" },
  -- quickfix
  { "<Leader>xx", "@quickfix.document_diagnostics" },
  { "<Leader>xX", "@quickfix.workspace_diagnostics" },
  { "<Leader>xl", "@quickfix.location_list" },
  { "<Leader>xq", "@quickfix.quickfix_list" },
  { "[t", "@goto.prev_todo" },
  { "]t", "@goto.next_todo" },
  { "<Leader>xt", "@quickfix.todo" },
  { "<Leader>xT", "@quickfix.todo_fixme" },
  { "<Leader>st", "@search.todo" },
  -- treesitter
  { "<C-Space>", "@treesitter.increase_selection" },
  { "<BS>", "@treesitter.decrease_selection" },
  -- notify
  { "<Leader>un", "@notify.clear" },
  { "<S-Enter>", "@notify.redirect" },
  { "<Leader>snl", "@notify.last" },
  { "<Leader>snh", "@notify.history" },
  { "<Leader>sna", "@notify.all" },
  -- buffer
  { "<S-h>", "@buffer.prev" },
  { "<S-l>", "@buffer.next" },
  { "[b", "@buffer.prev" },
  { "]b", "@buffer.next" },
  { "<Leader>bb", "@buffer.switch_back" },
  { "<Leader>`", "@buffer.switch_back" },
  { "<Leader>bd", "@buffer.close" },
  { "<Leader>bD", "@buffer.close_force" },
  { "<Leader>bp", "@buffer.toggle_pin" },
  { "<Leader>bP", "@buffer.close_ungrouped" },
  -- session
  { "<Leader>qq", "@session.quit" },
  { "<Leader>qs", "@session.restore" },
  { "<Leader>ql", "@session.restore_last" },
  { "<Leader>qd", "@session.stop" },
  -- util
  { "gw", "@util.search_this" },
  { "<Esc><Esc>", "@util.escape_terminal" },
  { "<A-j>", "@util.move_line_down" },
  { "<A-K>", "@util.move_line_up" },
  { "<C-s>", "@util.save" },
  -- undo break points
  { ",", "@util.undo_break_point" },
  { ".", "@util.undo_break_point" },
  { ";", "@util.undo_break_point" },
}

---@type DeltaVim.Keymap.Collector
local KEYMAPS

function M.init()
  local cfg = Util.load_config("config.keymaps")
  if type(cfg) == "function" then
    KEYMAPS = Keymap.load(cfg(M.DEFAULT))
  elseif cfg == false then
    KEYMAPS = Keymap.Collector()
  else
    KEYMAPS = Keymap.load(Util.concat({}, M.DEFAULT, cfg or {}))
  end
end

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
    { "@toggle.autoformat", require("deltavim.core.lsp").toggle_autoformat, "Toggle autoformat" },
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
    { "@util.escape_insert", "<Esc>", "Enter normal mode", mode = "i" },
    { "@util.escape_terminal", "<C-\\><C-n>", "Enter normal mode", mode = "t" },
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
  KEYMAPS:map(presets):collect_and_set()
end

return M
