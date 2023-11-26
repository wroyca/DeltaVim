local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")
local H = require("deltavim.helpers")

return {
  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    keys = function()
      return Keymap.Collector()
        :map({
          { "@search.notifications", H.telescope({ "notify" }), "Notifications" },
        })
        :collect_lazy()
    end,
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.4)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.4)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
    init = function()
      -- Install notify when `noice` is disabled
      if not Util.has("noice.nvim") and Util.has("nvim-notify") then
        Util.on_very_lazy(function()
          vim.notify = require("notify")
        end)
      end
    end,
    config = function(_, opts)
      require("notify").setup(opts)
      if Util.has("telescope.nvim") then
        require("telescope").load_extension("notify")
      end
    end,
  },

  -- Better vim.ui
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line:duplicate-set-field
      vim.ui.select = function(...)
        require("dressing")
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line:duplicate-set-field
      vim.ui.input = function(...)
        require("dressing")
        return vim.ui.input(...)
      end
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = function()
      return Keymap.Collector()
        :map({
          { "@buffer.close_left", "<Cmd>BufferLineCloseLeft<CR>", "Close left buffers" },
          { "@buffer.close_right", "<Cmd>BufferLineCloseRight<CR>", "Close right buffers" },
          -- stylua: ignore
          { "@buffer.close_others", "<Cmd>BufferLineCloseLeft<CR><Cmd>BufferLineCloseRight<CR>", "Close other buffers" },
          { "@buffer.close_ungrouped", "<Cmd>BufferLineGroupClose ungrouped<CR>", "Close ungrouped buffers" },
          { "@buffer.toggle_pin", "<Cmd>BufferLineTogglePin<CR>", "Toggle pin" },
          { "@buffer.prev", "<Cmd>BufferLineCyclePrev<CR>", "Prev buffer" },
          { "@buffer.next", "<Cmd>BufferLineCycleNext<CR>", "Next buffer" },
        })
        :collect_lazy()
    end,
    opts = function()
      local highlights
      if Config.colorscheme == "catppuccin" then
        highlights = require("catppuccin.groups.integrations.bufferline").get()
      end
      return {
        highlights = highlights,
        options = {
          close_command = H.bufremove(false),
          right_mouse_command = H.bufremove(false),
          diagnostics = "nvim_lsp",
          always_show_bufferline = false,
          diagnostics_indicator = function(_, _, diag)
            local icons = Config.icons.diagnostics
            local ret = (diag.error and icons.Error .. diag.error .. " " or "")
              .. (diag.warning and icons.Warn .. diag.warning or "")
            return vim.trim(ret)
          end,
          offsets = {
            {
              filetype = "neo-tree",
              text = "Explorer",
              highlight = "Directory",
              text_align = "left",
            },
          },
        },
      }
    end,
    config = function(_, opts)
      require("bufferline").setup(opts)
      -- Fix bufferline when restoring a session
      vim.api.nvim_create_autocmd("BufAdd", {
        callback = function()
          vim.schedule(function()
            pcall(nvim_bufferline)
          end)
        end,
      })
    end,
  },
  {
    "echasnovski/mini.bufremove",
    keys = function()
      return Keymap.Collector()
        :map({
          { "@buffer.close", H.bufremove(), "Delete buffer" },
          { "@buffer.close_force", H.bufremove(true), "Delete buffer (force)" },
        })
        :collect_lazy()
    end,
    config = true,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- Set an empty statusline till lualine loads
        vim.o.statusline = " "
      else
        -- Hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      -- PERF: we don't need this lualine require madness
      require("lualine_require").require = require

      local icons = Config.icons

      vim.o.laststatus = vim.g.lualine_laststatus

      local function fg(name)
        return function()
          ---@type {foreground?:number}?
          local hl = vim.api.nvim_get_hl(0, { name = name })
          return hl and hl.foreground and { fg = string.format("#%06x", hl.foreground) }
        end
      end

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            {
              "diagnostics",
              symbols = {
                error = icons.diagnostics.Error,
                warn = icons.diagnostics.Warn,
                info = icons.diagnostics.Info,
                hint = icons.diagnostics.Hint,
              },
            },
            {
              "filetype",
              icon_only = true,
              separator = "",
              padding = { left = 1, right = 0 },
            },
            {
              "filename",
              path = 1,
              symbols = { modified = "  ", readonly = "", unnamed = "" },
            },
          },
          lualine_x = {
            {
              function()
                ---@diagnostic disable-next-line: undefined-field
                return require("noice").api.status.command.get()
              end,
              cond = function()
                ---@diagnostic disable-next-line: undefined-field
                return package.loaded["noice"] and require("noice").api.status.command.has()
              end,
              color = fg("Statement"),
            },
            {
              function()
                ---@diagnostic disable-next-line: undefined-field
                return require("noice").api.status.mode.get()
              end,
              cond = function()
                ---@diagnostic disable-next-line: undefined-field
                return package.loaded["noice"] and require("noice").api.status.mode.has()
              end,
              color = fg("Constant"),
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = fg("Special"),
            },
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },
        extensions = {
          "lazy",
          "neo-tree",
          "quickfix",
          "toggleterm",
          "trouble",
        },
      }
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = "│",
        tab_char = "│",
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "lazyterm",
          "mason",
          "neo-tree",
          "notify",
          "toggleterm",
          "Trouble",
        },
      },
    },
  },

  -- Active indent guide
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      Util.autocmd("FileType", function()
        vim.b.miniindentscope_disable = true
      end, {
        pattern = {
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "Trouble",
        },
      })
    end,
  },

  -- Noicer UI
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
    keys = function()
      ---@param name string
      local function cmd(name)
        return function()
          require("noice").cmd(name)
        end
      end

      local function redirect()
        local cmdline = vim.fn.getcmdline()
        if cmdline ~= nil then
          require("noice").redirect(cmdline)
        end
      end

      ---@param delta number
      ---@return DeltaVim.Keymap.With
      local function scroll(delta)
        return function(src)
          local key = src[1] --[[@as string]]
          return function()
            if not require("noice.lsp").scroll(delta) then
              return Util.feedkey(key)
            end
          end
        end
      end

      return Keymap.Collector()
        :map({
          { "@notify.all", cmd("all"), "All notifications" },
          { "@notify.dismiss", cmd("dismiss"), "Dismiss notifications" },
          { "@notify.history", cmd("history"), "Notification history" },
          { "@notify.last", cmd("last"), "Last notification" },
          { "@notify.redirect", redirect, "Redirect to notification", mode = "c" },
          { "@cmp.scroll_up:noice", with = scroll(-4), desc = "Scroll up", mode = { "n", "i", "s" } },
          { "@cmp.scroll_down:noice", with = scroll(4), desc = "Scroll down", mode = { "n", "i", "s" } },
        })
        :collect_lazy()
    end,
  },

  -- Dashboard
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    -- init = function()
    --   -- Close Lazy and re-open when the dashboard is ready
    --   if vim.o.filetype == "lazy" then
    --     vim.cmd.close()
    --     vim.api.nvim_create_autocmd("User", {
    --       pattern = "DashboardLoaded",
    --       callback = function()
    --         require("lazy").show()
    --       end,
    --     })
    --   end
    -- end,
    opts = function()
      local logo = {
        "                                                             ",
        "                                                             ",
        "██████╗ ███████╗██╗  ████████╗ █████╗ ██╗   ██╗██╗███╗   ███╗",
        "██╔══██╗██╔════╝██║  ╚══██╔══╝██╔══██╗██║   ██║██║████╗ ████║",
        "██║  ██║█████╗  ██║     ██║   ███████║██║   ██║██║██╔████╔██║",
        "██║  ██║██╔══╝  ██║     ██║   ██╔══██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██████╔╝███████╗███████╗██║   ██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═════╝ ╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "                                                             ",
        "                                                             ",
      }
      ---@class DeltaVim.Config.Alpha

      ---@param key string
      ---@param icon string
      ---@param desc string
      ---@param action string|function
      local function btn(key, icon, desc, action)
        return {
          key = key,
          icon = icon,
          desc = desc,
          action = action,
        }
      end

      return {
        theme = "doom",
        hide = {
          -- This is taken care of by lualine, enabling this messes up the
          -- actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = logo,
          -- stylua: ignore
          center = {
            btn("n", "󱪝", "New file", "ene | startinsert"),
            btn("f", "󰱼", "Find files", H.telescope_files()),
            btn("r", "󰄉", "Recent files", "Telescope oldfiles"),
            btn("g", "", "Grep", H.telescope("live_grep")),
            btn("c", "", "Config", "e $MYVIMRC"),
            btn("s", "󰦛", "Restore session", function() require("persistence").load() end),
            btn("l", "󰒲", "Lazy", "Lazy"),
            btn("q", "", "Quit", "qa"),
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return {
              "",
              ("⚡ Neovim loaded %s plugins in %s ms"):format(stats.count, ms),
            }
          end,
        },
      }
    end,
    config = function(_, opts)
      if opts.config.center then
        for _, item in ipairs(opts.config.center) do
          item.icon = item.icon .. "  "
          item.desc = item.desc .. string.rep(" ", 36 - #item.desc)
        end
      end
      require("dashboard").setup(opts)
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- UI components
  { "MunifTanjim/nui.nvim", lazy = true },
}
