local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")
local H = require("deltavim.helpers")

return {
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    init = function()
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0) --[[@as any]])
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    deactivate = function()
      vim.cmd("Neotree close")
    end,
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

      return Keymap.Collector()
        :map({
          { "@explorer.toggle", toggle(Util.get_root), "Toggle explorer" },
          { "@explorer.toggle_cwd", toggle(Util.get_cwd), "Toggle explorer (cwd)" },
          { "@explorer.focus", focus(Util.get_root), "Focus explorer" },
          { "@explorer.focus_cwd", focus(Util.get_cwd), "Focus explorer (cwd)" },
        })
        :collect_lazy()
    end,
    opts = {
      sources = {
        "buffers",
        "document_symbols",
        "filesystem",
        "git_status",
      },
      open_files_do_not_replace_types = {
        "qf",
        "terminal",
        "Outline",
        "Trouble",
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    },
  },

  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = function()
      ---@param dir fun():string
      local function toggle(dir)
        ---@type Terminal
        return function()
          require("toggleterm").toggle(vim.v.count1, nil, dir())
        end
      end

      ---@param dir fun():string
      local function lazygit(dir)
        return function()
          require("toggleterm.terminal").Terminal
            :new({
              cmd = "lazygit",
              dir = dir(),
              id = 999,
              direction = "tab",
              shade_terminals = false,
              on_close = function()
                if package.loaded["neo-tree.sources.git_status"] then
                  require("neo-tree.sources.git_status").refresh()
                end
              end,
            })
            :toggle()
        end
      end

      return Keymap.Collector()
        :map({
          { "@terminal.select", "<Cmd>TermSelect<CR>", "Select terminal" },
          { "@terminal.open", toggle(Util.get_root), "Open terminal" },
          { "@terminal.open_cwd", toggle(Util.get_cwd), "Open terminal (cwd)" },
          { "@terminal.lazygit", lazygit(Util.get_root), "Lazygit" },
          { "@terminal.lazygit_cwd", lazygit(Util.get_cwd), "Lazygit (cwd)" },
        })
        :collect_lazy()
    end,
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return vim.o.lines * 0.4
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      persist_size = false,
      direction = "float",
      float_opts = { border = Config.border },
      ---@param term Terminal
      on_open = function(term)
        Keymap.Collector()
          :map({
            {
              "@terminal.hide",
              function()
                term:toggle()
              end,
              "Hide terminal",
              mode = "t",
              buffer = term.bufnr,
            },
          })
          :collect_and_set()
      end,
      shade_terminals = true,
      shading_factor = -15,
    },
  },

  -- Search/replace in multiple files
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = function()
        -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@search.replace", function() require("spectre").open() end, "Replace in files" },
        })
        :collect_lazy()
    end,
    config = true,
  },

  -- fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = { "telescope-fzf-native.nvim" },
    keys = function()
      local function get_root()
        return { cwd = Util.get_root() }
      end

      local function get_cwd()
        return { cwd = Util.get_cwd() }
      end

      ---@param document boolean
      ---@param level? string
      local function diagnostics(document, level)
        local bufnr
        if document then
          bufnr = 0
        end
        local severity = level and vim.diagnostic.severity[level] or nil
        return H.telescope("diagnostics", { bufnr = bufnr, severity = severity })
      end

      local builtin = H.telescope
      return Keymap.Collector()
        :map({
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
          { "@search.files", builtin("find_files", get_root), "Files" },
          { "@search.files_cwd", builtin("find_files", get_cwd), "Files (cwd)" },
          { "@search.gitfiles", builtin("git_files", get_root), "Git files" },
          { "@search.gitfiles_cwd", builtin("git_files", get_cwd), "Git files (cwd)" },
          { "@search.autofiles", H.telescope_files(get_root), "Tracked files" },
          { "@search.autofiles_cwd", H.telescope_files(get_cwd), "Tracked files (cwd)" },
          { "@search.oldfiles", builtin("oldfiles"), "Recent files" },
          { "@search.oldfiles_cwd", builtin("oldfiles", get_cwd), "Recent files (cwd)" },
          -- git
          { "@search.git_commits", builtin("git_commits"), "Git commits" },
          { "@search.git_status", builtin("git_status"), "Git status" },
          -- lsp
          { "@search.definitions", builtin("lsp_definitions"), "References" },
          { "@search.implementations", builtin("lsp_implementations"), "Implementations" },
          { "@search.references", builtin("lsp_references"), "References" },
          { "@search.type_definitions", builtin("lsp_type_definitions"), "Type definitions" },
          { "@search.document_diagnostics", diagnostics(true), "Document diagnostics" },
          { "@search.workspace_diagnostics", diagnostics(false), "Workspace diagnostics" },
          { "@search.document_errors", diagnostics(false, "E"), "Document errors" },
          { "@search.workspace_errors", diagnostics(true, "E"), "Workspace errors" },
          { "@search.document_warnings", diagnostics(false, "W"), "Document warnings" },
          { "@search.workspace_warnings", diagnostics(true, "W"), "Workspace warnings" },
          { "@search.document_symbols", builtin("lsp_document_symbols"), "Document symbols" },
          { "@search.workspace_symbols", builtin("lsp_workspace_symbols"), "Workspace symbols" },
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
        })
        :collect_lazy()
    end,
    opts = function()
      ---@param name string
      local function action(name)
        return function(...)
          return require("telescope.actions")[name](...)
        end
      end

      local function open_with_trouble(...)
        return require("trouble.providers.telescope").open_with_trouble(...)
      end

      local function open_selected_with_trouble(...)
        return require("trouble.providers.telescope").open_selected_with_trouble(...)
      end

      local mappings = {
        i = {
          ["<C-t>"] = open_with_trouble,
          ["<A-t>"] = open_selected_with_trouble,
          ["<A-i>"] = H.telescope_search_current({ no_ignore = true }),
          ["<A-h>"] = H.telescope_search_current({ hidden = true }),
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
          -- Open files in the first window that is an actual file.
          -- Use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then
                return win
              end
            end
            return 0
          end,
          mappings = mappings,
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
    enabled = vim.fn.executable("cmake") == 1 and (vim.fn.executable("gcc") or vim.fn.executable("clang")),
    config = function()
      Util.on_load("telescope.nvim", function()
        require("telescope").load_extension("fzf")
      end)
    end,
  },

  -- Easily jump to any location and enhanced f/t motions for Leap
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    vscode = true,
    ---@type Flash.Config
    opts = {
      modes = {
        char = {
          jump_labels = true,
          jump = {
            autojump = true,
            inclusive = true,
            nohlsearch = true,
          },
        },
      },
    },
    keys = function()
      ---@param forward boolean
      ---@param pos string
      local function jump(forward, pos)
        return function()
          require("flash").jump({
            search = {
              forward = forward,
              wrap = false,
              multi_window = false,
            },
            jump = {
              autojump = true,
              inclusive = true,
              nohlsearch = true,
              pos = pos,
            },
            label = {
              min_pattern_length = 2,
            },
          })
        end
      end

      ---@param name string
      ---@param act function
      ---@param desc string
      local function flash(name, act, desc)
        return { name, act, desc, mode = { "n", "x", "o" } }
      end

      -- stylua: ignore
      return Keymap.Collector():map({
        flash("@flash.forward_to", jump(true, "start"), "Flash forward to"),
        flash("@flash.backward_to", jump(false, "start"), "Flash backward to"),
        flash("@flash.forward_till", jump(true, "end"), "Flash forward to"),
        flash("@flash.backward_till", jump(false, "start"), "Flash backward to"),
      }):collect_lazy()
    end,
  },

  -- Which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
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
      window = { border = Config.border },
    },
    config = function(_, opts)
      local wk = require("which-key")
      -- Register operators
      local operators = Keymap.Collector()
        :map({
          { "@comment.oplead_line", "Toggle line comment" },
          { "@comment.oplead_block", "Toggle block comment" },
          { "@surround.add", "Add surrounding" },
        })
        :collect_lhs_table()
      opts = Util.deep_merge({ operators = operators }, opts)
      wk.setup(opts)
      -- Register defaults
      wk.register(opts.defaults)
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      ---@param name string
      ---@param args? any
      local function gs(name, args)
        return function()
          require("gitsigns")[name](args)
        end
      end

      ---@type DeltaVim.Keymap.Output[]
      local keymaps

      return {
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "" },
          topdelete = { text = "" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        preview_config = { border = "none" },
        on_attach = function(buffer)
          keymaps = keymaps
            or Keymap.Collector()
              :map({
                -- git
                { "@git.blame_line", gs("blame_line"), "Blame line" },
                { "@git.blame_line_full", gs("blame_line", { full = true }), "Blame line (full)" },
                { "@git.diffthis", gs("diffthis"), "Diff this" },
                { "@git.diffthis_last", gs("diffthis", "~"), "Diff this (last)" },
                { "@git.preview_hunk", gs("preview_hunk"), "Preview hunk" },
                { "@git.reset_buffer", gs("reset_buffer"), "Reset buffer" },
                { "@git.reset_hunk", gs("reset_hunk"), "Reset hunk" },
                { "@git.stage_buffer", gs("stage_buffer"), "Stage buffer" },
                { "@git.stage_hunk", gs("stage_hunk"), "State hunk", mode = { "n", "x" } },
                { "@git.undo_stage_hunk", gs("undo_stage_hunk"), "Undo stage hunk" },
                -- goto
                { "@goto.next_hunk", gs("next_hunk"), "Next hunk" },
                { "@goto.prev_hunk", gs("prev_hunk"), "Prev hunk" },
                -- toggle
                { "@toggle.blame_line", gs("toggle_current_line_blame"), "Toggle blame line" },
                -- select
                { "@textobject.hunk", gs("select_hunk"), "Select hunk", mode = "o" },
                { "@textobject.hunk", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk", mode = "x" },
              })
              :collect()
          Keymap.set(keymaps, { buffer = buffer })
        end,
      }
    end,
  },

  -- References
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    keys = function()
      return Keymap.Collector()
        :map({
          { "@goto.prev_reference", desc = "Prev reference" },
          { "@goto.next_reference", desc = "Next reference" },
        })
        :collect_lazy()
    end,
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = { providers = { "lsp" } },
    },
    config = function(_, opts)
      local illuminate = require("illuminate")
      illuminate.configure(opts)

      ---@param cmd string
      local function il(cmd)
        return function()
          illuminate[cmd]()
        end
      end

      local keymaps = Keymap.Collector()
        :map({
          { "@goto.prev_reference", il("goto_prev_reference"), "Prev reference" },
          { "@goto.next_reference", il("goto_next_reference"), "Next reference" },
        })
        :collect()
      Keymap.set(keymaps)

      -- Also set it after loading ftplugins, since a lot overwrite `[[`` and `]]`
      Util.autocmd("FileType", function(ev)
        Keymap.set(keymaps, { buffer = ev.buf })
      end)
    end,
  },

  -- Better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = function()
      local tb = H.trouble

      local goto_opts = { skip_groups = true, jump = true }
      ---@param next boolean
      local function goto_qf(next)
        local f = next and "next" or "previous"
        local f2 = next and "cnext" or "cprev"
        return function()
          local trouble = require("trouble")
          if trouble.is_open() then
            trouble[f](goto_opts)
          else
            vim.cmd(f2)
          end
        end
      end

      ---@param document boolean
      ---@param level? string
      local function diagnostics(document, level)
        local severity = level and vim.diagnostic.severity[level] or nil
        return H.trouble("deltavim", { workspace = not document, severity = severity })
      end

      return Keymap.Collector()
        :map({
          { "@goto.prev_quickfix", goto_qf(false), "Prev quickfix" },
          { "@goto.next_quickfix", goto_qf(true), "Next quickfix" },
          { "@quickfix.definitions", tb("lsp_definitions"), "Definitions" },
          { "@quickfix.document_diagnostics", diagnostics(true), "Document diagnostics" },
          { "@quickfix.workspace_diagnostics", diagnostics(false), "Workspace diagnostics" },
          { "@quickfix.document_errors", diagnostics(true, "E"), "Document errors" },
          { "@quickfix.workspace_errors", diagnostics(false, "E"), "Workspace errors" },
          { "@quickfix.document_warnings", diagnostics(true, "W"), "Document warnings" },
          { "@quickfix.workspace_warnings", diagnostics(false, "W"), "Workspace warnings" },
          { "@quickfix.implementations", tb("lsp_implementations"), "Implementations" },
          { "@quickfix.location_list", tb("loclist"), "Location list" },
          { "@quickfix.quickfix_list", tb("quickfix"), "Quickfix dist" },
          { "@quickfix.references", tb("lsp_references"), "References" },
          { "@quickfix.type_definitions", tb("lsp_type_definitions"), "Type definitions" },
        })
        :collect_lazy()
    end,
    opts = { use_diagnostic_signs = true },
    config = function(_, opts)
      -- Refersh diagnostics
      Util.autocmd("DiagnosticChanged", function()
        require("trouble").refresh({ auto = true, provider = "deltavim" })
      end)
      require("trouble").setup(opts)
    end,
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    keys = function()
      ---@param name string
      local function todo(name)
        return function()
          require("todo-comments")[name]()
        end
      end

      ---@param args? table
      local function telescope(args)
        return H.telescope({ "todo-comments", "todo" }, args)
      end

      ---@param args? table
      local function trouble(args)
        return H.trouble("todo", args)
      end

      local keywords = { keywords = "TODO,FIX,FIXME" }
      return Keymap.Collector()
        :map({
          { "@goto.next_todo", todo("jump_next"), "Next todo" },
          { "@goto.prev_todo", todo("jump_prev"), "Prev todo" },
          { "@search.todo", telescope(), "Todo" },
          { "@search.todo_fixme", telescope(keywords), "Todo/Fix/Fixme" },
          { "@quickfix.todo", trouble(), "Todo" },
          { "@quickfix.todo_fixme", trouble(keywords), "Todo/Fix/Fixme" },
        })
        :collect_lazy()
    end,
    config = true,
  },
}
