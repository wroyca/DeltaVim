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
  { "<Leader>-", "@window.split" },
  { "<Leader>|", "@window.vsplit" },
  { "<Leader>w-", "@window.split" },
  { "<Leader>w|", "@window.vsplit" },
  { "<Leader>ww", "@window.switch_back" },
  { "<Leader>wd", "@window.close" },
  -- ui
  { "<Leader>l", "@ui.lazy" },
  { "<Leader>uc", "@toggle.conceallevel" },
  { "<Leader>uC", "@search.colorschemes" },
  { "<Leader>ud", "@toggle.diagnostics" },
  { "<Leader>uf", "@toggle.autoformat" },
  { "<Leader>ui", "@util.show_pos" },
  { "<Leader>ul", "@toggle.line_number" },
  { "<Leader>ur", "@ui.refresh" },
  { "<Leader>us", "@toggle.spell" },
  { "<Leader>uw", "@toggle.wrap" },
  -- tab
  { "<Leader><Tab><Tab>", "@tab.new" },
  { "<Leader><Tab>[", "@tab.prev" },
  { "<Leader><Tab>]", "@tab.next" },
  { "<Leader><Tab>d", "@tab.close" },
  { "<Leader><Tab>f", "@tab.first" },
  { "<Leader><Tab>l", "@tab.last" },
  -- cmp/snippet
  { "<Tab>", "@snippet.next_node" },
  { "<S-Tab>", "@snippet.prev_node" },
  { "<Down>", "@cmp.next_item" },
  { "<Up>", "@cmp.prev_item" },
  { "<CR>", "@cmp.confirm" },
  { "<C-b>", "@cmp.scroll_up" },
  { "<C-e>", "@cmp.abort" },
  { "<C-f>", "@cmp.scroll_down" },
  { "<C-n>", "@cmp.next_item" },
  { "<C-p>", "@cmp.prev_item" },
  { "<C-Space>", "@cmp.complete" },
  { "<C-y>", "@cmp.confirm" },
  -- surround
  { "gza", "@surround.add" },
  { "gzd", "@surround.delete" },
  { "gzf", "@surround.find" },
  { "gzF", "@surround.find_left" },
  { "gzh", "@surround.highlight" },
  { "gzn", "@surround.update_n_lines" },
  { "gzr", "@surround.replace" },
  -- comment
  { "gc", "@comment.toggle" },
  { "gcc", "@comment.toggle_line" },
  -- file/find
  { "<Leader><Leader>", "@search.files" },
  { "<Leader>e", "@explorer.toggle" },
  { "<Leader>E", "@explorer.toggle_cwd" },
  { "<Leader>fb", "@search.buffers" },
  { "<Leader>fe", "@explorer.toggle" },
  { "<Leader>fE", "@explorer.toggle_cwd" },
  { "<Leader>ff", "@search.files" },
  { "<Leader>fF", "@search.files_cwd" },
  { "<Leader>fn", "@util.new_file" },
  { "<Leader>fr", "@search.oldfiles" },
  -- terminal
  { "<C-t>", "@terminal.open" },
  { "<C-t>", "@terminal.hide" },
  { "<Leader>ft", "@terminal.open" },
  { "<Leader>fT", "@terminal.open_cwd" },
  -- search
  { "<Leader>,", "@search.buffers_all" },
  { "<Leader>:", "@search.command_history" },
  { "<Leader>sa", "@search.autocommands" },
  { "<Leader>sb", "@search.current_buffer" },
  { "<Leader>sc", "@search.command_history" },
  { "<Leader>sC", "@search.commands" },
  { "<Leader>sd", "@search.lsp_document_diagnostics" },
  { "<Leader>sD", "@search.lsp_workspace_diagnostics" },
  { "<Leader>sg", "@search.grep" },
  { "<Leader>sG", "@search.grep_cwd" },
  { "<Leader>sh", "@search.help_tags" },
  { "<Leader>sH", "@search.highlights" },
  { "<Leader>sk", "@search.keymaps" },
  { "<Leader>sM", "@search.man_pages" },
  { "<Leader>sm", "@search.marks" },
  { "<Leader>so", "@search.options" },
  { "<Leader>sr", "@search.replace" },
  { "<Leader>sR", "@search.resume" },
  { "<Leader>ss", "@search.lsp_document_symbols" },
  { "<Leader>sS", "@search.lsp_workspace_symbols" },
  -- TODO: PR to LazyVim
  { "<Leader>st", "@search.todo" },
  { "<Leader>sT", "@search.todo_fixme" },
  { "<Leader>sw", "@search.words" },
  { "<Leader>sW", "@search.words_cwd" },
  -- git
  { "]h", "@goto.next_hunk" },
  { "[h", "@goto.prev_hunk" },
  { "ih", "@select.hunk" },
  { "<Leader>gc", "@search.git_commits" },
  { "<Leader>gg", "@terminal.lazygit" },
  { "<Leader>gG", "@terminal.lazygit_cwd" },
  { "<Leader>gs", "@search.git_status" },
  -- hunk
  { "<Leader>ghb", "@git.blame_line" },
  { "<Leader>ghB", "@git.blame_line_full" },
  { "<Leader>ghd", "@git.diffthis" },
  { "<Leader>ghD", "@git.diffthis_last" },
  { "<Leader>ghp", "@git.preview_hunk" },
  { "<Leader>ghR", "@git.reset_buffer" },
  { "<Leader>ghr", "@git.reset_hunk" },
  { "<Leader>ghS", "@git.stage_buffer" },
  { "<Leader>ghs", "@git.stage_hunk" },
  { "<Leader>ghu", "@git.undo_stage_hunk" },
  -- leap/flit
  { "s", "@leap.forward_to" },
  { "S", "@leap.backward_to" },
  { "gs", "@leap.from_window" },
  -- goto references
  { "[[", "@goto.prev_reference" },
  { "]]", "@goto.next_reference" },
  -- quickfix
  { "[t", "@goto.prev_todo" },
  { "]t", "@goto.next_todo" },
  { "[x", "@goto.prev_quickfix" },
  { "]x", "@goto.next_quickfix" },
  { "<Leader>xl", "@quickfix.location_list" },
  { "<Leader>xq", "@quickfix.quickfix_list" },
  { "<Leader>xt", "@quickfix.todo" },
  { "<Leader>xT", "@quickfix.todo_fixme" },
  { "<Leader>xx", "@quickfix.document_diagnostics" },
  { "<Leader>xX", "@quickfix.workspace_diagnostics" },
  -- lsp
  { "[d", "@goto.prev_diagnostic" },
  { "]d", "@goto.next_diagnostic" },
  { "[e", "@goto.prev_error" },
  { "]e", "@goto.next_error" },
  { "[w", "@goto.prev_warning" },
  { "]w", "@goto.next_warning" },
  { "gd", "@search.lsp_definitions" },
  { "gD", "@lsp.declaration" },
  { "gI", "@search.lsp_implementations" },
  { "gk", "@lsp.signature_help", mode = "n" },
  { "gr", "@search.lsp_references" },
  { "gt", "@search.lsp_type_definitions" },
  { "K", "@lsp.hover" },
  { "<C-k>", "@lsp.signature_help", mode = "i" },
  { "<Leader>ca", "@lsp.code_action" },
  { "<Leader>cd", "@lsp.line_diagnostics" },
  { "<Leader>cf", "@lsp.format" },
  { "<Leader>cl", "@ui.lsp_info" },
  -- treesitter
  { "<C-Space>", "@treesitter.increase_selection" },
  { "<BS>", "@treesitter.decrease_selection" },
  -- notify
  { "<S-Enter>", "@notify.redirect" },
  { "<Leader>un", "@notify.clear" },
  { "<Leader>sna", "@notify.all" },
  { "<Leader>snh", "@notify.history" },
  { "<Leader>snl", "@notify.last" },
  -- buffer
  { "<S-h>", "@buffer.prev" },
  { "<S-l>", "@buffer.next" },
  { "[b", "@buffer.prev" },
  { "]b", "@buffer.next" },
  { "<Leader>`", "@buffer.switch_back" },
  { "<Leader>bb", "@buffer.switch_back" },
  { "<Leader>bd", "@buffer.close" },
  { "<Leader>bD", "@buffer.close_force" },
  { "<Leader>bP", "@buffer.close_ungrouped" },
  { "<Leader>bp", "@buffer.toggle_pin" },
  -- session
  { "<Leader>qd", "@session.stop" },
  { "<Leader>ql", "@session.restore_last" },
  { "<Leader>qq", "@session.quit" },
  { "<Leader>qs", "@session.restore" },
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
local CONFIG

function M.init()
  local cfg = Util.load_config("config.keymaps")
  if cfg == false then
    CONFIG = Keymap.Collector()
  else
    CONFIG = Keymap.load(Util.reduce("list", {}, M.DEFAULT, cfg or {}))
  end
end

function M.setup()
  ---@type DeltaVim.Keymap.With
  local function undo_break_point(src)
    local key = src[1]
    return {
      key,
      key .. "<C-g>u",
    }
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
    { "@util.save", "<Cmd>w<CR><Esc>", "Save file", mode = { "*", "i", "x" } },
    { "@util.new_file", "<Cmd>enew<CR>", "New file" },
    { "@util.search_this", "*N", "Search this word", mode = { "n", "x" } },
    { "@util.escape_insert", "<Esc>", "Enter normal mode", mode = "i" },
    { "@util.escape_terminal", "<C-\\><C-n>", "Enter normal mode", mode = "t" },
    { "@util.undo_break_point", with = undo_break_point, mode = "i" },
    -- Move line up & down
    { "@util.move_line_down", "<Cmd>m .+1<CR>==", "Move line down", mode = "n" },
    { "@util.move_line_down", "<Esc><Cmd>m .+1<CR>==gi", "Move line down", mode = "i" },
    { "@util.move_line_down", ":m '>+1<CR>gv=gv", "Move line down", mode = "v" },
    { "@util.move_line_up", "<Cmd>m .-2<CR>==", "Move line up", mode = "n" },
    { "@util.move_line_up", "<Esc><Cmd>m .-2<CR>==gi", "Move line up", mode = "i" },
    { "@util.move_line_up", ":m '<-2<CR>gv=gv", "Move line up", mode = "v" },
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
  -- Fallback presets
  ---@type table<string,DeltaVim.Keymap.Presets>
  local fallback = {
    ["bufferline.nvim"] = {
      { "@buffer.prev", "<Cmd>bprevious<CR>", "Prev buffer" },
      { "@buffer.next", "<Cmd>bnext<CR>", "Next buffer" },
    },
    ["trouble.nvim"] = {
      { "@goto.prev_quickfix", "<Cmd>cprev<CR>", "Prev quickfix" },
      { "@goto.next_quickfix", "<Cmd>cnext<CR>", "Next quickfix" },
      { "@quickfix.location_list", "<Cmd>lopen<CR>", "Location list" },
      { "@quickfix.quickfix_list", "<Cmd>copen<CR>", "Quickfix dist" },
    },
  }
  for k, v in pairs(fallback) do
    if not Util.has(k) then Util.concat(presets, v) end
  end
  CONFIG:map(presets):collect_and_set()
end

return M
