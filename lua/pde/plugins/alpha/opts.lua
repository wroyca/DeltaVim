local dashboard = require "alpha.themes.dashboard"
local icon = require("astroui").get_icon

---@param lhs string Shortcut string of a button mapping
---@param rhs function|string? Righthand side of the mapping
---@param icon string Icon of the button
---@param desc string Text description of the button
---@param map_opts table? Additional options to create the mappings
---@diagnostic disable-next-line: redefined-local
dashboard.button = function(lhs, rhs, icon, desc, map_opts)
  local default_opts = {
    noremap = true,
    silent = true,
    nowait = true,
    desc = desc,
  }
  map_opts = (map_opts and vim.tbl_extend("force", default_opts, map_opts)) or default_opts

  return {
    type = "button",
    val = icon .. "  " .. desc,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(lhs .. "<Ignore>", true, false, true)
      vim.api.nvim_feedkeys(key, "t", false)
    end,
    opts = {
      position = "center",
      shortcut = lhs,
      cursor = -2,
      width = 36,
      align_shortcut = "right",
      hl = "DashboardCenter",
      hl_shortcut = "DashboardShortcut",
      keymap = { "n", lhs, rhs, map_opts },
    },
  }
end

-- header
-- credit: https://github.com/MaximilianLloyd/ascii.nvim/blob/c1a315e/lua/ascii/text/neovim.lua#L224-L235
dashboard.section.header.val = {
  [[                                                                     ]],
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
}
dashboard.section.header.opts.hl = "DashboardHeader"

-- body
local last_session = require("pde.plugins.resession.mappings").load_dir_cwd[1]
dashboard.section.buttons.val = {
  dashboard.button("n", "<Cmd>enew<CR>", icon "FileNew", "New File"),
  dashboard.button("f", "<Cmd>Telescope find_files<CR>", icon "Search", "Find File"),
  dashboard.button("o", "<Cmd>Telescope oldfiles<CR>", icon "DefaultFile", "Recents"),
  dashboard.button("g", "<Cmd>Telescope live_grep<CR>", icon "WordFile", "Grep"),
  dashboard.button("b", "<Cmd>Telescope marks<CR>", icon "Bookmarks", "Bookmarks"),
  dashboard.button("r", last_session, icon "Refresh", "Last Session"),
  dashboard.button("q", "<Cmd>confirm qa<CR>", icon "Exit", "Quit"),
}

-- footer
dashboard.section.footer.val = { "Hello, NeoVim!" }
dashboard.section.footer.opts.hl = "DashboardFooter"

-- layout
dashboard.config.layout = {
  { type = "padding", val = 7 },
  dashboard.section.header,
  { type = "padding", val = 5 },
  dashboard.section.buttons,
  { type = "padding", val = 3 },
  dashboard.section.footer,
}

dashboard.config.opts.noautocmd = true -- manually fire the FileType event
return dashboard
