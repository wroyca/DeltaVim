-- credit: https://github.com/AstroNvim/astrocommunity/blob/41f7a6a/lua/astrocommunity/recipes/heirline-nvchad-statusline/init.lua#

local status, icon = require "astroui.status", require("astroui").get_icon

---@param cond function
local cond_not = function(cond)
  return function(...) return not cond(...) end
end

return {
  opts = {
    colors = require("astroui").config.status.setup_colors(),
    disable_winbar_cb = function(args)
      return not require("astrocore.buffer").is_valid(args.buf)
        or status.condition.buffer_matches({ buftype = { "terminal", "nofile" } }, args.buf)
    end,
  },

  -------------
  -- bufferline
  -------------

  tabline = {
    -- automatic sidebar padding
    {
      condition = function(self)
        self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
        self.winwidth = vim.api.nvim_win_get_width(self.winid)
        return self.winwidth ~= vim.o.columns -- only apply to sidebars
          and not require("astrocore.buffer").is_valid(vim.api.nvim_win_get_buf(self.winid))
      end,
      provider = function(self) return (" "):rep(self.winwidth + 1) end,
      hl = { bg = "tabline_bg" },
    },

    status.heirline.make_buflist(status.component.tabline_file_info()),
    status.component.fill { hl = { bg = "tabline_bg" } },

    {
      -- hide tabline until there are 1+ tabs
      condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
      status.heirline.make_tablist {
        provider = status.provider.tabnr(),
        hl = function(self)
          return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true)
        end,
      },
      { -- close button for current tab
        provider = status.provider.close_button {
          kind = "TabClose",
          padding = { left = 1, right = 1 },
        },
        hl = status.hl.get_attributes("tab_close", true),
        on_click = {
          name = "heirline_tabline_close_tab_callback",
          callback = function() require("astrocore.buffer").close_tab() end,
        },
      },
    },
  },

  ---------
  -- winbar
  ---------

  winbar = {
    init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
    fallthrough = false,
    {
      condition = cond_not(status.condition.is_active),
      status.component.separated_path(),
      status.component.file_info {
        file_icon = { hl = status.hl.file_icon "winbar", padding = { left = 0 } },
        filename = {},
        filetype = false,
        file_read_only = false,
        hl = status.hl.get_attributes("winbarnc", true),
        surround = false,
        update = "BufEnter",
      },
    },
    status.component.breadcrumbs { hl = status.hl.get_attributes("winbar", true) },
  },

  -------------
  -- statusline
  -------------

  statusline = {
    hl = { fg = "fg", bg = "bg" },

    ------------------
    -- left components
    ------------------

    status.component.mode {
      mode_text = { icon = { kind = "VimIcon", padding = { right = 1 } } },
      padding = { left = 1, right = 1 },
      surround = {
        separator = "left",
        color = function() return { main = status.hl.mode_bg(), right = "section_bg" } end,
      },
    },

    status.component.file_info {
      filetype = { icon = { kind = "DefaultFile", padding = { right = 1 } } },
      filename = false,
      file_icon = false,
      file_modified = false,
      file_read_only = false,
      padding = { left = 1, right = 1 },
      surround = {
        condition = cond_not(status.condition.is_git_repo),
        separator = "left",
        color = { main = "section_bg" },
      },
    },

    status.component.git_branch {
      git_branch = { padding = false },
      padding = { left = 1, right = 1 },
      surround = {
        condition = status.condition.is_git_repo,
        separator = "left",
        color = { main = "section_bg" },
      },
    },

    status.component.git_diff {
      surround = { separator = "none" },
    },

    status.component.cmd_info {
      macro_recording = { padding = { left = 0, right = 1 } },
      search_count = { padding = { left = 0, right = 1 } },
      showcmd = { padding = { left = 0, right = 1 } },
      padding = { left = 1 },
      surround = { separator = "none" },
    },

    --------------------
    -- center components
    --------------------
    status.component.fill(),

    -------------------
    -- right components
    -------------------

    status.component.lsp {
      lsp_client_names = false,
      lsp_progress = { padding = false },
      padding = { right = 1 },
      surround = { separator = "none", color = "bg" },
    },
    status.component.diagnostics {
      padding = { right = 1 },
      surround = { separator = "none" },
    },
    status.component.lsp {
      lsp_client_names = { icon = { padding = { right = 1 } } },
      lsp_progress = false,
      padding = { right = 1 },
      surround = { separator = "none" },
    },

    { -- nav
      status.component.builder {
        { provider = icon "ScrollText" },
        padding = { right = 1 },
        hl = { fg = "mode_fg" },
        surround = { separator = "right", color = "nav_icon_bg" },
      },
      status.component.nav {
        percentage = { padding = false },
        ruler = false,
        scrollbar = false,
        padding = { left = 1, right = 1 },
        surround = { separator = "none", color = "section_bg" },
      },
    },

    { -- project
      status.component.builder {
        { provider = icon "FolderClosed" },
        hl = { fg = "mode_fg" },
        padding = { right = 1 },
        surround = {
          separator = "right",
          color = { main = "folder_icon_bg", left = "section_bg" },
        },
      },
      status.component.file_info {
        filename = {
          fname = function(buf) return vim.fn.getcwd(buf) end,
        },
        filetype = false,
        file_icon = false,
        file_modified = false,
        file_read_only = false,
        padding = { left = 1, right = 1 },
        surround = { condition = false, separator = "none", color = "section_bg" },
      },
    },

    { -- virtualenv
      condition = status.condition.has_virtual_env,
      status.component.builder {
        { provider = icon "Environment" },
        hl = { fg = "mode_fg" },
        padding = { right = 1 },
        surround = {
          separator = "right",
          color = { main = "virtual_env_icon_bg", left = "section_bg" },
        },
      },
      status.component.virtual_env {
        virtual_env = { icon = { kind = "NONE" }, padding = false },
        padding = { left = 1, right = 1 },
        surround = { condition = false, separator = "none", color = "section_bg" },
      },
    },
  },

  statuscolumn = {
    init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
    status.component.signcolumn(),
    status.component.numbercolumn(),
    status.component.foldcolumn(),
  },
}
