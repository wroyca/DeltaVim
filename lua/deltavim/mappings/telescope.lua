return {
  { cond = "telescope.nvim" },

  resume = {
    function() require("telescope.builtin").resume() end,
    desc = "Resume previous search",
  },

  git_branches = {
    function() require("telescope.builtin").git_branches { use_file_path = true } end,
    desc = "Git branches",
  },

  git_buffer_commits = {
    function() require("telescope.builtin").git_bcommits { use_file_path = true } end,
    desc = "Git commits (buffer)",
  },

  git_global_commits = {
    function() require("telescope.builtin").git_commits { use_file_path = true } end,
    desc = "Git commits (global)",
  },

  git_status = {
    function() require("telescope.builtin").git_status { use_file_path = true } end,
    desc = "Git status",
  },

  find_buffer_fuzzy = {
    function() require("telescope.builtin").current_buffer_fuzzy_find() end,
    desc = "Find fuzzy words (buffer)",
  },

  find_words = {
    function() require("telescope.builtin").live_grep() end,
    desc = "Find words",
  },

  find_words_from_all = {
    function()
      require("telescope.builtin").live_grep {
        additional_args = { "--hidden", "--no-ignore" },
      }
    end,
    desc = "Find words in all files",
  },

  find_marks = {
    function() require("telescope.builtin").marks() end,
    desc = "Find marks",
  },

  find_config_files = {
    function()
      require("telescope.builtin").find_files {
        prompt_title = "Config Files",
        cwd = vim.fn.stdpath "config",
        follow = true,
      }
    end,
    desc = "Find NeoVim config files",
  },

  find_buffers = {
    function() require("telescope.builtin").buffers() end,
    desc = "Find buffers",
  },

  find_command_history = {
    function() require("telescope.builtin").command_history() end,
    desc = "Find command history",
  },

  find_commands = {
    function() require("telescope.builtin").commands() end,
    desc = "Find commands",
  },

  find_autocmds = {
    function() require("telescope.builtin").autocommands() end,
    desc = "Find autocommands",
  },

  find_files = {
    function() require("telescope.builtin").find_files() end,
    desc = "Find files",
  },

  find_all_files = {
    function() require("telescope.builtin").find_files { hidden = true, no_ignore = true } end,
    desc = "Find all files",
  },

  find_help_tags = {
    function() require("telescope.builtin").help_tags() end,
    desc = "Find help tags",
  },

  find_keymaps = {
    function() require("telescope.builtin").keymaps() end,
    desc = "Find keymaps",
  },

  find_man_pages = {
    function() require("telescope.builtin").man_pages() end,
    desc = "Find man pages",
  },

  find_recent_files = {
    function() require("telescope.builtin").oldfiles() end,
    desc = "Find recent files",
  },

  find_registers = {
    function() require("telescope.builtin").registers() end,
    desc = "Find registers",
  },

  find_colorschemes = {
    function() require("telescope.builtin").colorscheme { enable_preview = true } end,
    desc = "Find colorschemes",
  },

  find_highlights = {
    function() require("telescope.builtin").highlights() end,
    desc = "Find highlight groups",
  },

  find_current_word = {
    function() require("telescope.builtin").grep_string() end,
    desc = "Find word under cursor",
  },

  ----------------
  -- LSP specified
  ----------------

  goto_definition = {
    function() require("telescope.builtin").lsp_definitions() end,
    desc = "Goto symbol definition",
    cond = "textDocument/definition",
  },

  goto_type_definition = {
    function() require("telescope.builtin").lsp_type_definitions() end,
    desc = "Goto symbol type definition",
    cond = "textDocument/typeDefinition",
  },

  find_implementations = {
    function() require("telescope.builtin").lsp_implementations() end,
    desc = "Find symbol implementations",
    cond = "textDocument/implementation",
  },

  find_references = {
    function() require("telescope.builtin").lsp_references() end,
    desc = "Find symbol references",
    cond = "textDocument/references",
  },

  find_document_diagnostics = {
    function() require("telescope.builtin").diagnostics { bufnr = 0 } end,
    desc = "Find document diagnostics",
  },

  find_workspace_diagnostics = {
    function() require("telescope.builtin").diagnostics() end,
    desc = "Find workspace diagnostics",
  },

  find_document_errors = {
    function()
      require("telescope.builtin").diagnostics {
        bufnr = 0,
        severity = vim.diagnostic.severity.E,
      }
    end,
    desc = "Find document diagnostics",
  },

  find_workspace_errors = {
    function()
      require("telescope.builtin").diagnostics {
        severity = vim.diagnostic.severity.E,
      }
    end,
    desc = "Find workspace diagnostics",
  },

  find_document_symbols = {
    function() require("telescope.builtin").lsp_document_symbols() end,
    desc = "Find document symbols",
    cond = "workspace/symbol",
  },

  find_workspace_symbols = {
    function() require("telescope.builtin").lsp_workspace_symbols() end,
    desc = "Find workspace symbols",
    cond = "workspace/symbol",
  },
}
