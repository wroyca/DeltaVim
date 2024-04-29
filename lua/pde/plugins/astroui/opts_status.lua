local sign_handlers = {}

-- gitsigns handlers
local gitsigns_handler = function(_)
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then vim.schedule(gitsigns.preview_hunk) end
end
for _, sign in ipairs { "Topdelete", "Untracked", "Add", "Change", "Changedelete", "Delete" } do
  sign_handlers["GitSigns" .. sign] = gitsigns_handler
end
sign_handlers["gitsigns_extmark_signs_"] = gitsigns_handler

-- diagnostic handlers
local diagnostics_handler = function(args)
  if args.mods:find "c" then
    vim.schedule(vim.lsp.buf.code_action)
  else
    vim.schedule(vim.diagnostic.open_float)
  end
end
for _, sign in ipairs { "Error", "Hint", "Info", "Warn" } do
  sign_handlers["DiagnosticSign" .. sign] = diagnostics_handler
end

return {
  sidebar_titles = {
    ["neo-tree"] = "Explorer",
    ["aerial"] = "Symbols",
  },
  modes = {
    ["n"] = { "NORMAL", "normal" },
    ["no"] = { "OP", "normal" },
    ["nov"] = { "OP", "normal" },
    ["noV"] = { "OP", "normal" },
    ["no"] = { "OP", "normal" },
    ["niI"] = { "NORMAL", "normal" },
    ["niR"] = { "NORMAL", "normal" },
    ["niV"] = { "NORMAL", "normal" },
    ["i"] = { "INSERT", "insert" },
    ["ic"] = { "INSERT", "insert" },
    ["ix"] = { "INSERT", "insert" },
    ["t"] = { "TERM", "terminal" },
    ["nt"] = { "TERM", "terminal" },
    ["v"] = { "VISUAL", "visual" },
    ["vs"] = { "VISUAL", "visual" },
    ["V"] = { "LINES", "visual" },
    ["Vs"] = { "LINES", "visual" },
    [""] = { "BLOCK", "visual" },
    ["s"] = { "BLOCK", "visual" },
    ["R"] = { "REPLACE", "replace" },
    ["Rc"] = { "REPLACE", "replace" },
    ["Rx"] = { "REPLACE", "replace" },
    ["Rv"] = { "V-REPLACE", "replace" },
    ["s"] = { "SELECT", "visual" },
    ["S"] = { "SELECT", "visual" },
    [""] = { "BLOCK", "visual" },
    ["c"] = { "COMMAND", "command" },
    ["cv"] = { "COMMAND", "command" },
    ["ce"] = { "COMMAND", "command" },
    ["r"] = { "PROMPT", "inactive" },
    ["rm"] = { "MORE", "inactive" },
    ["r?"] = { "CONFIRM", "inactive" },
    ["!"] = { "SHELL", "inactive" },
    ["null"] = { "null", "inactive" },
  },
  separators = {
    none = { "", "" },
    breadcrumbs = "  ",
    path = "  ",
    left = { "", "" },
    right = { "", "" },
    tab = { "", "" },
  },
  attributes = {
    mode = { bold = true },
    buffer_active = { bold = true, italic = true },
    buffer_picker = { bold = true },
    sidebar_title = { bold = true },
  },
  icon_highlights = {
    file_icon = {
      tabline = function(self) return self.is_active or self.is_visible end,
      statusline = false,
    },
  },
  sign_handlers = sign_handlers,
  setup_colors = function()
    local astroui, utils = require "astroui", require "pde.utils"
    local status, config = require "astroui.status", astroui.config.status
    local error_hl = { fg = "red", bg = "red" }

    local _hlgroup = astroui.get_hlgroup
    local function hlgroup(name) return _hlgroup(name, error_hl) end

    local _lualine_hl = status.hl.lualine_mode
    local function lualine_hl(name, mode, fallback)
      local hl = hlgroup(name)
      return hl == error_hl and { bg = _lualine_hl(mode, fallback.fg) } or hl
    end

    local Comment = hlgroup "Comment"
    local Error = hlgroup "Error"
    local Function = hlgroup "Function"
    local Keyword = hlgroup "Keyword"
    local Normal = hlgroup "Normal"
    local Number = hlgroup "Number"
    local StatusLine = hlgroup "StatusLine"
    local String = hlgroup "String"
    local TabLine = hlgroup "TabLine"
    local TabLineFill = hlgroup "TabLineFill"
    local TabLineSel = hlgroup "TabLineSel"
    local TypeDef = hlgroup "TypeDef"
    local Visual = hlgroup "Visual"
    local WinBar = hlgroup "WinBar"
    local WinBarNC = hlgroup "WinBarNC"

    local GitSignsAdd = hlgroup "GitSignsAdd"
    local GitSignsChange = hlgroup "GitSignsChange"
    local GitSignsDelete = hlgroup "GitSignsDelete"

    local DiagnosticError = hlgroup "DiagnosticError"
    local DiagnosticWarn = hlgroup "DiagnosticWarn"
    local DiagnosticInfo = hlgroup "DiagnosticInfo"
    local DiagnosticHint = hlgroup "DiagnosticHint"

    local HeirlineNormal = lualine_hl("HeirlineNormal", "normal", Function)
    local HeirlineInsert = lualine_hl("HeirlineInsert", "insert", String)
    local HeirlineReplace = lualine_hl("HeirlineReplace", "replace", Number)
    local HeirlineVisual = lualine_hl("HeirlineVisual", "visual", Keyword)
    local HeirlineCommand = lualine_hl("HeirlineCommand", "command", TypeDef)
    local HeirlineTerminal = _hlgroup("HeirlineTerminal", HeirlineCommand)
    local HeirlineInactive = _hlgroup("HeirlineInactive", HeirlineNormal)

    local colors = {
      -- bufferline
      buffer_fg = TabLine.fg,
      buffer_bg = Normal.bg,
      buffer_path_fg = TabLine.fg,
      buffer_close_fg = TabLine.fg,

      buffer_active_fg = Normal.fg,
      buffer_active_bg = Normal.bg,
      buffer_active_path_fg = TabLine.fg,
      buffer_active_close_fg = Error.fg,

      buffer_visible_fg = Normal.fg,
      buffer_visible_bg = Normal.bg,
      buffer_visible_path_fg = TabLine.fg,
      buffer_visible_close_fg = Error.fg,

      buffer_overflow_fg = Normal.fg,
      buffer_overflow_bg = TabLineFill.bg,

      buffer_picker_fg = Error.fg,

      -- tabline
      tabline_fg = TabLineFill.fg,
      tabline_bg = TabLineFill.bg,

      tab_fg = TabLine.fg,
      tab_bg = TabLine.bg,

      tab_active_fg = TabLineSel.fg,
      tab_active_bg = TabLineSel.bg,

      tab_close_fg = Error.fg,
      tab_close_bg = TabLineFill.bg,

      -- winbar
      winbar_fg = WinBar.fg,
      winbar_bg = WinBar.bg,
      winbarnc_fg = WinBarNC.fg,
      winbarnc_bg = WinBarNC.bg,

      -- statusline
      fg = StatusLine.fg,
      bg = StatusLine.bg,

      mode_fg = StatusLine.bg,
      section_fg = Visual.fg,
      section_bg = Visual.bg,

      normal = HeirlineNormal.bg,
      insert = HeirlineInsert.bg,
      visual = HeirlineVisual.bg,
      replace = HeirlineReplace.bg,
      command = HeirlineCommand.bg,
      terminal = HeirlineTerminal.bg,
      inactive = HeirlineInactive.bg,

      git_added = GitSignsAdd.fg,
      git_changed = GitSignsChange.fg,
      git_removed = GitSignsDelete.fg,

      diag_ERROR = DiagnosticError.fg,
      diag_WARN = DiagnosticWarn.fg,
      diag_INFO = DiagnosticInfo.fg,
      diag_HINT = DiagnosticHint.fg,

      scrollbar = TypeDef.fg,
      nav_icon_bg = String.fg,
      folder_icon_bg = Error.fg,
      virtual_env_icon_bg = Function.fg,
    }

    -- add missing colors
    for _, c in ipairs { "sidebar_title" } do
      colors[c .. "_fg"] = Normal.fg
      colors[c .. "_bg"] = TabLine.bg
    end
    for _, c in ipairs {
      "file_info",
      "git_branch",
      "nav",
      "virtual_env",
    } do
      colors[c .. "_fg"] = colors.section_fg
    end
    for _, c in ipairs {
      "git_diff",
      "cmd_info",
      "lsp",
      "diagnostics",
      "treesitter",
    } do
      colors[c .. "_fg"] = Comment.fg
      colors[c .. "_bg"] = colors.bg
    end

    -- load user defined colors
    local user_colors = config.colors
    if type(user_colors) == "table" then
      utils.merge(colors, user_colors)
    elseif type(user_colors) == "function" then
      colors = user_colors(colors)
    end

    return colors
  end,
}
