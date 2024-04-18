return {
  "goolord/alpha-nvim",
  cmd = "Alpha",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local map = opts.mappings
        map.n["<Leader>h"] = {
          function()
            local wins = vim.api.nvim_tabpage_list_wins(0)
            if #wins > 1 and vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype == "neo-tree" then
              vim.fn.win_gotoid(wins[2]) -- go to non-neo-tree window to toggle Alpha
            end
            require("alpha").start(false)
          end,
          desc = "Home Screen",
        }

        local au = opts.autocmds
        au.alpha_autostart = {
          {
            event = "VimEnter",
            desc = "Start Alpha when vim is opened without arguments",
            once = true,
            callback = function()
              if vim.fn.argc() > 0 then return end
              require("lazy").load { plugins = { "alpha-nvim" } }
              require("alpha").start(true)
              vim.schedule(function() vim.cmd.doautocmd "FileType" end)
            end,
          },
        }
        au.alpha_settings = {
          {
            event = { "User", "BufWinEnter" },
            desc = "Disable status, tablines, and cmdheight for Alpha",
            callback = function(ev)
              local before = vim.g.before_alpha
              local opt = vim.opt

              if
                not before
                and (
                  (ev.event == "User" and ev.file == "AlphaReady")
                  or (ev.event == "BufWinEnter" and vim.bo[ev.buf].filetype == "alpha")
                )
              then
                ---@diagnostic disable: undefined-field
                vim.g.before_alpha = {
                  showtabline = opt.showtabline:get(),
                  laststatus = opt.laststatus:get(),
                  cmdheight = opt.cmdheight:get(),
                }
                opt.showtabline, opt.laststatus, opt.cmdheight = 0, 0, 0
              elseif
                before
                and ev.event == "BufWinEnter"
                and vim.bo[ev.buf].buftype ~= "nofile"
              then
                opt.laststatus, opt.showtabline, opt.cmdheight =
                  before.laststatus, before.showtabline, before.cmdheight
                vim.g.before_alpha = nil
              end
            end,
          },
        }
      end,
    },
  },
  opts = function()
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
    dashboard.section.buttons.val = {
      dashboard.button("n", "<Cmd>enew<CR>", icon "FileNew", "New File"),
      dashboard.button("f", "<Cmd>Telescope find_files<CR>", icon "Search", "Find File"),
      dashboard.button("o", "<Cmd>Telescope oldfiles<CR>", icon "DefaultFile", "Recents"),
      dashboard.button("g", "<Cmd>Telescope live_grep<CR>", icon "WordFile", "Grep"),
      dashboard.button("b", "<Cmd>Telescope marks<CR>", icon "Bookmarks", "Bookmarks"),
      dashboard.button("r", "", icon "Refresh", "Last Session"),
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
  end,
  config = require "pde.plugins.configs.alpha",
}
