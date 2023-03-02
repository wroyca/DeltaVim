local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    deactivate = function() vim.cmd("Neotree close") end,
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0) --[[@as any]])
        if stat and stat.type == "directory" then require("neo-tree") end
      end
    end,
    opts = {
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
    keys = function()
      ---@param dir fun():string
      ---@return fun()
      local function toggle(dir)
        return function()
          require("neo-tree.command").execute({ toggle = true, dir = dir() })
        end
      end

      ---@param dir fun():string
      ---@return fun()
      local function focus(dir)
        return function()
          require("neo-tree.command").execute({ focus = true, dir = dir() })
        end
      end

      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets = {
        { "@explorer.toggle", toggle(Util.get_root), "Toggle explorer" },
        { "@explorer.toggle_cwd", toggle(Util.get_cwd), "Toggle explorer (cwd)" },
        { "@explorer.focus", focus(Util.get_root), "Focus explorer" },
        { "@explorer.focus_cwd", focus(Util.get_cwd), "Focus explorer (cwd)" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
  },

  -- TODO: PR to LazyVim
  {
    "akinsho/toggleterm.nvim",
    keys = function()
      ---@param opts fun():table
      local function create(opts)
        return function()
          require("toggleterm.terminal").Terminal:new(opts()):open()
        end
      end

      ---@param dir fun():string
      local function toggle(dir)
        ---@type Terminal
        return function() require("toggleterm").toggle(vim.v.count1, nil, dir()) end
      end

      ---@param dir fun():string
      local function lazygit(dir)
        -- stylua: ignore
        return create(function() return { cmd = "lazygit", dir = dir(), id = 999 } end)
      end

      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets = {
        { "@terminal.open", toggle(Util.get_root), "Open terminal" },
        { "@terminal.open_cwd", toggle(Util.get_cwd), "Open terminal (cwd)" },
        { "@terminal.lazygit", lazygit(Util.get_root), "Lazygit" },
        { "@terminal.lazygit_cwd", lazygit(Util.get_cwd), "Lazygit (cwd)" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
    opts = {
      direction = "float",
      ---@param term Terminal
      on_open = function(term)
        Keymap.Collector()
          :map1({
            "@terminal.hide",
            function() term:toggle() end,
            "Hide terminal",
            mode = "t",
            buffer = term.bufnr,
          })
          :collect_and_set()
      end,
    },
  },

  -- Search/replace in multiple files
  {
    "windwp/nvim-spectre",
    opts = {},
    keys = function()
      return Keymap.Collector()
        :map1({
          "@search.replace",
          function() require("spectre").open() end,
          desc = "Replace in files",
        })
        :collect_lazy()
    end,
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = function()
      local function get_root()
        return {
          cwd = Util.get_root(),
        }
      end

      local function get_cwd()
        return {
          cwd = Util.get_cwd(),
        }
      end

      ---@param cmd string
      ---@param args? table|fun():table
      local function builtin(cmd, args)
        if type(args) == "function" then
          return function() Util.telescope(cmd, args()) end
        else
          return function() Util.telescope(cmd, args) end
        end
      end

      ---@param opts fun():table
      local function files(opts)
        return function() Util.telescope_files(opts()) end
      end

      local symbols = {
        symbols = {
          "Class",
          "Function",
          "Method",
          "Constructor",
          "Interface",
          "Module",
          "Struct",
          "Trait",
          "Field",
          "Property",
        },
      }

      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets = {
        -- buffers
        { "@search.buffers", builtin("buffers"), "Buffers" },
        { "@search.buffers_all", builtin("buffers", { show_all_buffers = true }), "All buffers" },
        -- grep
        { "@search.grep", builtin("live_grep", get_root), "Grep" },
        { "@search.grep_cwd", builtin("live_grep", get_cwd), "Grep (cwd)" },
        -- word
        { "@search.words", builtin("grep_string", get_root), "Words" },
        { "@search.words_cwd", builtin("grep_string", get_cwd), "Words (cwd)" },
        -- files
        { "@search.files", files(get_root), "Files" },
        { "@search.files_cwd", files(get_cwd), "Files (cwd)" },
        { "@search.oldfiles", builtin("oldfiles"), "Recent files" },
        -- git
        { "@search.git_commits", builtin("git_commits"), "Git commits" },
        { "@search.git_status", builtin("git_status"), "Git status" },
        -- lsp
        { "@search.lsp_definitions", builtin("lsp_definitions"), "References" },
        { "@search.lsp_implementations", builtin("lsp_implementations"), "Implementations" },
        { "@search.lsp_references", builtin("lsp_references"), "References" },
        { "@search.lsp_type_definitions", builtin("lsp_type_definitions"), "Type definitions" },
        -- TODO: PR to LazyVim
        { "@search.lsp_document_diagnostics", builtin("diagnostics", { bufnr = 0 }), "Document diagnostics" },
        { "@search.lsp_workspace_diagnostics", builtin("diagnostics"), "Workspace diagnostics" },
        { "@search.lsp_document_symbols", builtin("lsp_document_symbols", symbols), "Document symbols" },
        { "@search.lsp_workspace_symbols", builtin("lsp_workspace_symbols", symbols), "Workspace symbols" },
        -- others
        { "@search.autocommands", builtin("autocommands"), "Auto Commands" },
        { "@search.colorschemes", builtin("colorscheme", { enable_preview = true }), "Colorschemes" },
        { "@search.command_history", builtin("command_history"), "Command history" },
        { "@search.commands", builtin("commands"), "Commands" },
        { "@search.current_buffer", builtin("current_buffer_fuzzy_find"), "Current buffer" },
        { "@search.help_tags", builtin("help_tags"), "Help pages" },
        { "@search.highlights", builtin("highlights"), "Highlight groups" },
        { "@search.keymaps", builtin("keymaps"), "Keymaps" },
        { "@search.man_pages", builtin("man_pages"), "Man Pages" },
        { "@search.marks", builtin("marks"), "Marks" },
        { "@search.options", builtin("vim_options"), "Options" },
        { "@search.resume", builtin("resume"), "Resume" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
    opts = function()
      ---@param name string
      local function action(name)
        return function(...) return require("telescope.actions")[name](...) end
      end

      ---@param opts table
      local function files(opts)
        return function()
          opts.cwd = Util.get_root()
          Util.telescope_files(opts)
        end
      end

      local function open_with_trouble(...)
        return require("trouble.providers.telescope").open_with_trouble(...)
      end

      local mappings = {
        i = {
          ["<c-t>"] = open_with_trouble,
          ["<a-i>"] = files({ no_ignore = true }),
          ["<a-h>"] = files({ hidden = true }),
          ["<C-Down>"] = action("cycle_history_next"),
          ["<C-Up>"] = action("cycle_history_prev"),
          ["<C-f>"] = action("preview_scrolling_down"),
          ["<C-b>"] = action("preview_scrolling_up"),
        },
        n = {
          ["q"] = action("close"),
        },
      }
      return {
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          mappings = mappings,
        },
      }
    end,
  },

  -- Easily jump to any location and enhanced f/t motions for Leap
  {
    "ggandor/leap.nvim",
    keys = function()
      ---@param name string
      ---@param key string
      ---@param desc string
      local function leap(name, key, desc)
        return { name, key, desc, mode = { "n", "x", "o" }, remap = false }
      end
      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets = {
        leap("@leap.forward_to", "<Plug>(leap-forward-to)", "Leap forward to"),
        leap("@leap.backward_to", "<Plug>(leap-backward-to)", "Leap backward to"),
        leap("@leap.forward_till", "<Plug>(leap-forward-till)", "Leap forward till"),
        leap("@leap.backward_till", "<Plug>(leap-backward-till)", "Leap backward till"),
        leap("@leap.from_window", "<Plug>(leap-from-window)", "Leap from window"),
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
    config = function(_, opts) Util.merge(require("leap").opts, opts) end,
  },
  {
    "ggandor/flit.nvim",
    keys = function()
      local keys = {}
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        table.insert(keys, { key, mode = { "n", "x", "o" }, desc = key })
      end
      return keys
    end,
    opts = { labeled_modes = "nxo" },
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      groups = {
        mode = { "n", "x" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["g"] = { name = "+goto" },
        ["gz"] = { name = "+surround" },
        ["<Leader>b"] = { name = "+buffer" },
        ["<Leader>c"] = { name = "+code" },
        ["<Leader>f"] = { name = "+file/find" },
        ["<Leader>g"] = { name = "+git" },
        ["<Leader>gh"] = { name = "+hunks" },
        ["<Leader>q"] = { name = "+quit/session" },
        ["<Leader>s"] = { name = "+search" },
        ["<Leader>sn"] = { name = "+noice" },
        ["<Leader>u"] = { name = "+ui" },
        ["<Leader>w"] = { name = "+windows" },
        ["<Leader>x"] = { name = "+diagnostics/quickfix" },
        ["<Leader><Tab>"] = { name = "+tabs" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.groups)
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      ---@param buffer integer
      local function on_attach(buffer)
        ---@param name string
        ---@param args? any
        local function gs(name, args)
          return function() require("gitsigns")[name](args) end
        end

        local full = { full = true }
        -- stylua: ignore
        ---@type DeltaVim.Keymap.Presets
        local presets = {
          -- git
          { "@git.blame_line", gs("blame_line"), "Blame line" },
          { "@git.blame_line_full", gs("blame_line", full), "Blame line (full)" },
          { "@git.diffthis", gs("diffthis"), "Diff this" },
          { "@git.diffthis_last", gs("diffthis", "~"), "Diff this (last)" },
          { "@git.preview_hunk", gs("preview_hunk"), "Preview hunk" },
          { "@git.reset_buffer", gs("reset_buffer"), "Reset buffer" },
          { "@git.reset_hunk", gs("reset_hunk"), "Reset hunk" },
          { "@git.stage_buffer", gs("stage_buffer"), "Stage buffer" },
          { "@git.stage_hunk", gs("stage_hunk"), "State hunk" },
          { "@git.undo_stage_hunk", gs("undo_stage_hunk"), "Undo stage hunk" },
          -- goto
          { "@goto.next_hunk", gs("next_hunk"), "Next hunk" },
          { "@goto.prev_hunk", gs("prev_hunk"), "Prev hunk" },
          -- toggle
          { "@toggle.blame_line", gs("toggle_current_line_blame"), "Toggle blame line" },
          -- select
          { "@select.hunk", gs("select_hunk"), "Select hunk", mode = { "o", "x" } },
          buffer = buffer,
        }
        Keymap.Collector():map(presets):collect_and_set()
      end

      return {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        on_attach = on_attach,
      }
    end,
  },

  -- References
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = { delay = 200 },
    keys = function()
      return Keymap.Collector()
        :map({
          { "@goto.prev_reference", desc = "Prev reference" },
          { "@goto.next_reference", desc = "Next reference" },
        })
        :collect_lazy()
    end,
    config = function(_, opts)
      local illuminate = require("illuminate")
      illuminate.configure(opts)

      ---@param cmd string
      local function il(cmd)
        return function() illuminate[cmd]() end
      end

      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets = {
        { "@goto.prev_reference", il("goto_prev_reference"), "Prev reference" },
        { "@goto.next_reference", il("goto_next_reference"), "Next reference" },
      }
      local keymaps = Keymap.Collector():map(presets):collect()
      Keymap.set(keymaps)

      -- Also set it after loading ftplugins, since a lot overwrite `[[`` and `]]`
      Util.autocmd(
        "FileType",
        function(ev) Keymap.set(keymaps, { buffer = ev.buf }) end
      )
    end,
  },

  -- Better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = function()
      ---@param mode string
      local function tb(mode)
        return function() require("trouble").toggle({ mode = mode }) end
      end

      ---@param next boolean
      local function goto_qf(next)
        local f = next and "next" or "previous"
        return function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble[f]({ skip_groups = true, jump = true })
          end
        end
      end

      -- stylua: ignore
      local presets = {
        { "@goto.prev_quickfix", goto_qf(false), "Prev quickfix" },
        { "@goto.next_quickfix", goto_qf(true), "Next quickfix" },
        { "@quickfix.definitions", tb("lsp_definitions"), "Definitions" },
        { "@quickfix.document_diagnostics", tb("document_diagnostics"), "Document diagnostics" },
        { "@quickfix.implementations", tb("lsp_implementations"), "Implementations" },
        { "@quickfix.location_list", tb("loclist"), "Location list" },
        { "@quickfix.quickfix_list", tb("quickfix"), "Quickfix dist" },
        { "@quickfix.references", tb("lsp_references"), "References" },
        { "@quickfix.type_definitions", tb("lsp_type_definitions"), "Type definitions" },
        { "@quickfix.workspace_diagnostics", tb("workspace_diagnostics"), "Workspace diagnostics" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = function()
      ---@param name string
      local function todo(name)
        return function() require("todo-comments")[name]() end
      end

      ---@param args? table
      local function trouble(args)
        args = Util.merge({ mode = "todo" }, args or {})
        return function() require("trouble").toggle(args) end
      end

      ---@param args? table
      local function telescope(args)
        return function()
          require("telescope").extensions["todo-comments"].todo(args)
        end
      end

      local keywords = { keywords = "TODO,FIX,FIXME" }
      -- stylua: ignore
      ---@type DeltaVim.Keymap.Presets
      local presets = {
        { "@goto.next_todo", todo("jump_next"), "Next todo" },
        { "@goto.prev_todo", todo("jump_prev"), "Prev todo" },
        -- TODO: PR to LazyVim
        { "@search.todo", telescope(), "Todo" },
        { "@search.todo_fixme", telescope(keywords), "Todo/Fix/Fixme" },
        { "@quickfix.todo", trouble(), "Todo" },
        { "@quickfix.todo_fixme", trouble(keywords), "Todo/Fix/Fixme" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
  },
}
