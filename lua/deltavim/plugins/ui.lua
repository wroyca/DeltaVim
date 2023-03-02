local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

return {
  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    keys = function()
      local opts = { silent = true, pending = true }
      -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@notify.clear", function() require("notify").dismiss(opts) end, "Delete all notifications" },
          { "@search.notifications", Util.telescope({ "notify" }), "Notifications" },
        })
        :collect_lazy()
    end,
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
    },
    init = function()
      -- Install notify when `noice` is disabled
      if not Util.has("noice.nvim") then
        Util.on_very_lazy(function() vim.notify = require("notify") end)
      end
    end,
    config = function(_, opts)
      require("notify").setup(opts)
      -- TODO: PR to LazyVim
      require("telescope").load_extension("notify")
    end,
  },

  -- Better vim.ui
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line:duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line:duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- Bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = function()
      -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@buffer.close_left", "<Cmd>BufferLineCloseLeft<CR>", "Close left buffers" },
          { "@buffer.close_right", "<Cmd>BufferLineCloseRight<CR>", "Close right buffers" },
          { "@buffer.close_ungrouped", "<Cmd>BufferLineGroupClose ungrouped<CR>", "Close ungrouped buffers" },
          { "@buffer.toggle_pin", "<Cmd>BufferLineTogglePin<CR>", "Toggle pin" },
          { "@buffer.prev", "<Cmd>BufferLineCyclePrev<CR>", "Prev buffer" },
          { "@buffer.next", "<Cmd>BufferLineCycleNext<CR>", "Next buffer" },
        })
        :collect_lazy()
    end,
    opts = {
      options = {
        -- TODO: PR to LazyVim
        close_command = Util.bufremove(true),
        right_mouse_command = Util.bufremove(true),
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
        diagnostics_indicator = function(_, _, diag)
          local icons = Config.icons.diagnostics
          ---@type string[]
          local s = {}
          if diag.error then table.insert(s, icons.Error .. diag.error) end
          if diag.warning then table.insert(s, icons.Warn .. diag.warning) end
          return table.concat(s, " ")
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
    },
  },
  {
    "echasnovski/mini.bufremove",
    keys = function()
      -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@buffer.close", Util.bufremove(), "Delete buffer" },
          { "@buffer.close_force", Util.bufremove(true), "Delete buffer (force)" },
        })
        :collect_lazy()
    end,
    config = function(_, opts) require("mini.bufremove").setup(opts) end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local icons = Config.icons

      local function fg(name)
        return function()
          ---@type {foreground?:number}?
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl
            and hl.foreground
            and { fg = string.format("#%06x", hl.foreground) }
        end
      end

      return {
        options = {
          theme = "auto",
          globalstatus = true,
          disabled_filetypes = { statusline = { "dashboard", "lazy", "alpha" } },
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
            {
              function() return require("nvim-navic").get_location() end,
              cond = function() return require("nvim-navic").is_available() end,
            },
          },
          lualine_x = {
            {
              function() return require("noice").api.status.command.get() end,
              cond = function()
                return require("noice").api.status.command.has()
              end,
              color = fg("Statement"),
            },
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return require("noice").api.status.mode.has() end,
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
            function() return " " .. os.date("%R") end,
          },
        },
        extensions = { "neo-tree" },
      }
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      char = "│",
      filetype_exclude = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
      },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    },
  },

  -- Active indent guide
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      Util.autocmd(
        "FileType",
        function() vim.b.miniindentscope_disable = true end,
        {
          pattern = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "lazy",
            "mason",
          },
        }
      )
    end,
    config = function(_, opts) require("mini.indentscope").setup(opts) end,
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
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    keys = function()
      ---@param name string
      local function cmd(name)
        return function() require("noice").cmd(name) end
      end

      local function redirect() require("noice").redirect(vim.fn.getcmdline()) end

      -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@notify.all", cmd("all"), "All notifications" },
          { "@notify.history", cmd("history"), "Notification history" },
          { "@notify.last", cmd("last"), "Last notification" },
          { "@notify.redirect", redirect, "Redirect to notification", mode = "c" },
        })
        :collect_lazy()
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      local logo = {
        "██████╗ ███████╗██╗  ████████╗ █████╗ ██╗   ██╗██╗███╗   ███╗",
        "██╔══██╗██╔════╝██║  ╚══██╔══╝██╔══██╗██║   ██║██║████╗ ████║",
        "██║  ██║█████╗  ██║     ██║   ███████║██║   ██║██║██╔████╔██║",
        "██║  ██║██╔══╝  ██║     ██║   ██╔══██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██████╔╝███████╗███████╗██║   ██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═════╝ ╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }

      ---@param key string
      ---@param icon string
      ---@param desc string
      ---@param action string|function
      local function button(key, icon, desc, action)
        local opts = { noremap = true, silent = true, nowait = true }
        if type(action) == "function" then
          opts.callback = action
          action = ""
        end
        local btn = dashboard.button(key, icon .. " " .. desc, action, opts)
        btn.opts.hl = "AlphaButtons"
        btn.opts.hl_shortcut = "AlphaShortcut"
        return btn
      end

      -- header
      dashboard.section.header.val = logo
      dashboard.section.header.opts.hl = "AlphaHeader"
      -- body
      -- stylua: ignore
      dashboard.section.buttons.val = {
        button("f", " ", " Find file", Util.telescope_files),
        button("n", " ", " New file", "<Cmd>ene<BAR>startinsert<CR>"),
        button("r", " ", " Recent files", ":Telescope oldfiles <CR>"),
        button("g", " ", " Find text", Util.telescope("live_grep")),
        button("c", " ", " Config", "<Cmd>e $MYVIMRC<CR>"),
        button("s", "󰑓 ", " Restore session", function() require("persistence").load() end),
        button("l", "󰒲 ", " Lazy", "<Cmd>Lazy<CR>"),
        button("q", " ", " Quit", "<Cmd>qa<CR>"),
      }
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      -- footer
      -- stylua: ignore
      dashboard.section.footer.val = ("Hello, %s!"):format(vim.env["USER"] or "NeoVim")
      dashboard.section.footer.opts.hl = "Type"
      dashboard.opts.layout[1].val = 8
      return dashboard
    end,
    keys = function()
      return Keymap.Collector()
        :map1({ "@ui.alpha", "<Cmd>Alpha<CR>", "Alpha" })
        :collect_lazy()
    end,
    config = function(_, dashboard)
      -- Close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        Util.autocmd(
          "User",
          function() require("lazy").show() end,
          { pattern = "AlphaReady" }
        )
      end

      require("alpha").setup(dashboard.opts)

      -- Show plugins summary
      Util.autocmd("User", function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        -- stylua: ignore
        dashboard.section.footer.val = ("⚡ Neovim loaded %s plugins in %d ms"):format(stats.count, ms)
        pcall(vim.cmd.AlphaRedraw)
      end, { pattern = "LazyVimStarted" })
    end,
  },

  -- Lsp symbol navigation for lualine
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      Util.on_lsp_attach(function(client, buffer)
        if client.server_capabilities.documentSymbolProvider then
          require("nvim-navic").attach(client, buffer)
        end
      end)
    end,
    opts = function()
      return {
        separator = " ",
        highlight = true,
        depth_limit = 5,
        icons = Config.icons.kinds,
      }
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- UI components
  { "MunifTanjim/nui.nvim", lazy = true },
}
