local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
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
  },

  -- Search/replace in multiple files
  {
    "windwp/nvim-spectre",
    opts = {},
    keys = function()
      return Keymap.Collector()
        :map({
          {
            "@search.replace",
            function() require("spectre").open() end,
            desc = "Replace in files",
          },
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
        -- commands
        { "@search.commands", builtin("commands"), "Commands" },
        { "@search.command_history", builtin("command_history"), "Command history" },
        -- colorscheme
        { "@search.highlights", builtin("highlights"), "Highlight groups" },
        { "@search.colorschemes", builtin("colorscheme", { enable_preview = true }), "Colorschemes" },
        -- help files
        { "@search.help_tags", builtin("help_tags"), "Help pages" },
        { "@search.man_pages", builtin("man_pages"), "Man Pages" },
        -- lsp
        { "@search.references", builtin("lsp_references"), "References" },
        { "@search.implementations", builtin("lsp_implementations"), "Implementations" },
        { "@search.type_definitions", builtin("lsp_type_definitions"), "Type definitions" },
        { "@search.document_diagnostics", builtin("diagnostics", { bufnr = 0 }), "Document diagnostics" },
        { "@search.workspace_diagnostics", builtin("diagnostics"), "Workspace diagnostics" },
        { "@search.document_symbols", builtin("lsp_document_symbols", symbols), "Document symbols" },
        { "@search.workspace_symbols", builtin("lsp_workspace_symbols", symbols), "Workspace symbols" },
        -- others
        { "@search.autocommands", builtin("autocommands"), "Auto Commands" },
        { "@search.keymaps", builtin("keymaps"), "Keymaps" },
        { "@search.marks", builtin("marks"), "Marks" },
        { "@search.options", builtin("vim_options"), "Options" },
        { "@search.current_buffer", builtin("current_buffer_fuzzy_find"), "Current buffer" },
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
    "ggandor/flit.nvim",
    keys = function()
      local keys = {}
      for _, key in ipairs({ "f", "F", "t", "T" }) do
        table.insert(keys, { key, mode = { "n", "x", "o" }, desc = key })
      end
      return keys
    end,
    opts = { labeled_modes = "nx" },
  },
  {
    "ggandor/leap.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
      { "x", mode = { "n", "x", "o" }, desc = "Leap exclusive forward to" },
      { "X", mode = { "n", "x", "o" }, desc = "Leap exclusive backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
    },
    config = function(_, opts)
      local leap = require("leap")
      Util.deep_merge(leap.opts, opts)
      leap.add_default_mappings(true)
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(Config.keymap_groups)
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
        local function gs(name, ...)
          local args = { ... }
          return function() require("gitsigns")[name](unpack(args)) end
        end

        -- stylua: ignore
        ---@type DeltaVim.Keymap.Presets
        local presets = {
          -- git
          { "@git.stage_hunk", gs("stage_hunk"), "State hunk" },
          { "@git.reset_hunk", gs("reset_hunk"), "Reset hunk" },
          { "@git.stage_buffer", gs("stage_buffer"), "Stage buffer" },
          { "@git.reset_buffer", gs("reset_buffer"), "Reset buffer" },
          { "@git.undo_stage_hunk", gs("undo_stage_hunk"), "Undo stage hunk" },
          { "@git.preview_hunk", gs("preview_hunk"), "Preview hunk" },
          { "@git.blame_line", gs("blame_line"), "Blame line" },
          { "@git.diffthis", gs("diffthis"), "Diff this" },
          { "@git.diffthis_last", gs("diffthis", "~"), "Diff this (last)" },
          -- goto
          { "@goto.next_hunk", gs("next_hunk"), "Next hunk" },
          { "@goto.prev_hunk", gs("prev_hunk"), "Prev hunk" },
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
          delete = { text = "契" },
          topdelete = { text = "契" },
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
          { "@goto.next_reference", desc = "Next reference" },
          { "@goto.prev_reference", desc = "Prev reference" },
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
        { "@goto.next_reference", il("goto_next_reference"), "Next reference" },
        { "@goto.prev_reference", il("goto_prev_reference"), "Prev reference" },
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

      -- stylua: ignore
      local presets = {
        { "@quickfix.definitions", tb("lsp_definitions"), "Definitions" },
        { "@quickfix.references", tb("lsp_references"), "References" },
        { "@quickfix.implementations", tb("lsp_implementations"), "Implementations" },
        { "@quickfix.type_definitions", tb("lsp_type_definitions"), "Type definitions" },
        { "@quickfix.document_diagnostics", tb("document_diagnostics"), "Document diagnostics" },
        { "@quickfix.workspace_diagnostics", tb("workspace_diagnostics"), "Workspace diagnostics" },
        { "@quickfix.location_list", tb("loclist"), "Location list" },
        { "@quickfix.quickfix_list", tb("quickfix"), "Quickfix dist" },
      }
      return Keymap.new():map(presets):collect_lazy()
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
        return function()
          require("trouble").toggle(vim.tbl_extend("force", {
            mode = "todo",
          }, args or {}))
        end
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
        { "@search.todo", telescope(), "Todo" },
        { "@search.todo_fixme", telescope(keywords), "Todo/Fix/Fixme" },
        { "@quickfix.todo", trouble(), "Todo" },
        { "@quickfix.todo_fixme", trouble(keywords), "Todo/Fix/Fixme" },
      }
      return Keymap.Collector():map(presets):collect_lazy()
    end,
  },
}
