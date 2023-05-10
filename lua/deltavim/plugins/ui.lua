local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")
local H = require("deltavim.helpers")

return {
  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    keys = function()
      -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@search.notifications", H.telescope({ "notify" }), "Notifications" },
        })
        :collect_lazy()
    end,
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.4) end,
      max_width = function() return math.floor(vim.o.columns * 0.4) end,
    },
    init = function()
      -- Install notify when `noice` is disabled
      if not Util.has("noice.nvim") and Util.has("notify") then
        Util.on_very_lazy(function() vim.notify = require("notify") end)
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
        close_command = H.bufremove(true),
        right_mouse_command = H.bufremove(true),
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
          { "@buffer.close", H.bufremove(), "Delete buffer" },
          { "@buffer.close_force", H.bufremove(true), "Delete buffer (force)" },
        })
        :collect_lazy()
    end,
    config = function(_, opts) require("mini.bufremove").setup(opts) end,
  },

  -- VS Code like winbar
  {
    "utilyre/barbecue.nvim",
    version = "*",
    event = "VeryLazy",
    opts = function()
      local kinds = {}
      for k, v in pairs(Config.icons.kinds) do
        -- Remove spaces
        kinds[k] = v:gsub(" ", "")
      end
      return {
        attach_navic = false,
        show_dirname = false,
        show_basename = true,
        kinds = kinds,
      }
    end,
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
          disabled_filetypes = { statusline = { "dashboard", "alpha" } },
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
            -- stylua: ignore
            {
              function() return require("noice").api.status.command.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
              color = fg("Statement"),
            },
            -- stylua: ignore
            {
              function() return require("noice").api.status.mode.get() end,
              cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
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
            function() return " " .. os.date("%R") end,
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
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      char = "│",
      context_char = "│",
      filetype_exclude = {
        "alpha",
        "dashboard",
        "help",
        "lazy",
        "mason",
        "neo-tree",
        "Trouble",
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
            "alpha",
            "dashboard",
            "help",
            "lazy",
            "mason",
            "neo-tree",
            "Trouble",
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
        lsp_doc_border = Config.border == "rounded",
      },
    },
    keys = function()
      ---@param name string
      local function cmd(name)
        return function() require("noice").cmd(name) end
      end

      local function redirect() require("noice").redirect(vim.fn.getcmdline()) end

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

      -- stylua: ignore
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
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local logo = {
        "██████╗ ███████╗██╗  ████████╗ █████╗ ██╗   ██╗██╗███╗   ███╗",
        "██╔══██╗██╔════╝██║  ╚══██╔══╝██╔══██╗██║   ██║██║████╗ ████║",
        "██║  ██║█████╗  ██║     ██║   ███████║██║   ██║██║██╔████╔██║",
        "██║  ██║██╔══╝  ██║     ██║   ██╔══██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██████╔╝███████╗███████╗██║   ██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═════╝ ╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
      }
      ---@class DeltaVim.Config.Alpha
      return {
        header = logo,
        -- stylua: ignore
        ---@type {[1]:string,[2]:string,[3]:string,[4]:string|fun()}[]
        buttons = {
          { "n", "󱪝 ", "New file", "<Cmd>ene<BAR>startinsert<CR>" },
          { "f", "󰱼 ", "Find files", H.telescope_files() },
          { "r", "󰄉 ", "Recent files", ":Telescope oldfiles <CR>" },
          { "g", " ", "Grep", H.telescope("live_grep") },
          { "c", " ", "Config", "<Cmd>e $MYVIMRC<CR>" },
          { "s", "󰦛 ", "Restore session", function() require("persistence").load() end, },
          { "l", "󰒲 ", "Lazy", "<Cmd>Lazy<CR>" },
          { "q", " ", "Quit", "<Cmd>qa<CR>" },
        },
      }
    end,
    keys = function()
      return Keymap.Collector()
        :map({
          { "@ui.alpha", "<Cmd>Alpha<CR>", "Alpha" },
        })
        :collect_lazy()
    end,
    ---@param opts DeltaVim.Config.Alpha
    config = function(_, opts)
      local dashboard = require("alpha.themes.dashboard")

      -- header
      dashboard.section.header.val = opts.header
      dashboard.section.header.opts.hl = "AlphaHeader"
      -- body
      local buttons = {}
      for _, btn in ipairs(opts.buttons) do
        local key, icon, desc, action = unpack(btn) --[[@as any]]
        local o = { noremap = true, silent = true, nowait = true }
        if type(action) == "function" then
          o.callback = action
          action = ""
        end
        local button = dashboard.button(key, icon .. " " .. desc, action, o)
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortCut"
        table.insert(buttons, button)
      end
      dashboard.section.buttons.val = buttons
      -- footer
      -- stylua: ignore
      dashboard.section.footer.val = ("Hello, %s!"):format(vim.env["USER"] or "NeoVim")
      dashboard.section.footer.opts.hl = "AlphaFooter"
      dashboard.opts.layout[1].val = 8

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
        dashboard.section.footer.val = ("⚡ Neovim loaded %s plugins in %s ms"):format(stats.count, ms)
        pcall(vim.cmd.AlphaRedraw)
      end, { pattern = "LazyVimStarted" })
    end,
  },

  -- Lsp symbol navigation for lualine
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      if Util.has("nvim-navic") then
        vim.g.navic_silence = true
        Util.on_lsp_attach(function(client, buffer)
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, buffer)
          end
        end)
      end
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
