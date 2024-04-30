return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local icon = require("astroui").get_icon

    require("pde.utils").make_mappings(opts.mappings, {
      n = {
        ------------------
        -- common mappings
        ------------------

        ["<"] = { "<gv" },
        [">"] = { ">gv" },
        ["<Esc>"] = { "<Cmd>noh<CR><Esc>" },
        ["gw"] = { "*N", noremap = true },

        ["j"] = "common.move_down",
        ["k"] = "common.move_up",
        ["gx"] = "common.system_open",

        ["<C-h>"] = "common.left_window",
        ["<C-j>"] = "common.down_window",
        ["<C-k>"] = "common.up_window",
        ["<C-l>"] = "common.right_window",
        ["<C-s>"] = "common.save_file",

        ["<C-S-h>"] = "common.resize_left",
        ["<C-S-j>"] = "common.resize_down",
        ["<C-S-k>"] = "common.resize_up",
        ["<C-S-l>"] = "common.resize_right",

        ["<Leader>n"] = "common.new_file",
        ["<Leader>-"] = "common.hsplit",
        ["<Leader>\\"] = "common.vsplit",

        ["<Leader>w"] = "buffer.close",
        ["<Leader>W"] = "common.close_window",

        --------------------
        -- package management
        --------------------

        ["<Leader>p"] = { desc = icon("Package", 1) .. "Packages" },
        ["<Leader>pc"] = "lazy.check",
        ["<Leader>pi"] = "lazy.install",
        ["<Leader>pp"] = "lazy.show_status",
        ["<Leader>ps"] = "lazy.sync",
        ["<Leader>pu"] = "lazy.update",

        --------------------
        -- editor components
        --------------------

        ["<Leader>h"] = "alpha.toggle",
        ["<Leader>e"] = "neo-tree.focus",

        ------------------
        -- editor features
        ------------------

        ["<Leader>u"] = { desc = icon("Setting", 1) .. "UI/UX" },
        ["<Leader>ub"] = "toggles.toggle_background",
        ["<Leader>ud"] = "toggles.toggle_diagnostics",
        ["<Leader>ug"] = "toggles.toggle_signcolumn",
        ["<Leader>ui"] = "toggles.toggle_indent",
        ["<Leader>ul"] = "toggles.toggle_statusline",
        ["<Leader>un"] = "toggles.toggle_number",
        ["<Leader>up"] = "toggles.toggle_paste",
        ["<Leader>us"] = "toggles.toggle_spell",
        ["<Leader>ut"] = "toggles.toggle_tabline",
        ["<Leader>uu"] = "toggles.toggle_url_match",
        ["<Leader>uw"] = "toggles.toggle_wrap",
        ["<Leader>uy"] = "toggles.toggle_syntax",
        ["<Leader>uz"] = "toggles.toggle_foldcolumn",
        ["<Leader>uA"] = "toggles.toggle_autochdir",
        ["<Leader>uN"] = "toggles.toggle_notifications",
        ["<Leader>uS"] = "toggles.toggle_conceal",

        ["<Leader>uc"] = "cmp.toggle_buffer",
        ["<Leader>uC"] = "cmp.toggle_global",
        ["<Leader>ua"] = "autopairs.toggle_global",

        --------------------
        -- buffer management
        --------------------

        ["[b"] = "buffer.prev",
        ["]b"] = "buffer.next",
        ["<C-,>"] = "buffer.prev",
        ["<C-.>"] = "buffer.next",

        ["<b"] = "buffer.move_left",
        [">b"] = "buffer.move_right",

        ["<Leader>b"] = { desc = icon("Tab", 1) .. "Buffers" },
        ["<Leader>bH"] = "buffer.close_left",
        ["<Leader>bL"] = "buffer.close_right",
        ["<Leader>bQ"] = "buffer.close_others",

        ["<Leader>bs"] = { desc = icon("Sort", 1) .. "Sort buffers" },
        ["<Leader>bse"] = "buffer.sort_by_extension",
        ["<Leader>bsf"] = "buffer.sort_by_filename",
        ["<Leader>bsp"] = "buffer.sort_by_path",
        ["<Leader>bsn"] = "buffer.sort_by_number",
        ["<Leader>bsm"] = "buffer.sort_by_modification",

        ["<Leader>bb"] = "heirline.pick_select",
        ["<Leader>bq"] = "heirline.pick_close",
        ["<Leader>b\\"] = "heirline.pick_hsplit",
        ["<Leader>b-"] = "heirline.pick_vsplit",

        ["[t"] = "buffer.prev",
        ["]t"] = "buffer.next",

        ["<Leader>t"] = { desc = icon("Window", 1) .. "Tabs" },
        ["<Leader>tn"] = "tab.new",
        ["<Leader>tq"] = "tab.close",
        ["<Leader>th"] = "tab.goto_first",
        ["<Leader>tl"] = "tab.goto_last",

        ---------------------
        -- session management
        ---------------------

        ["<Leader>q"] = { desc = icon("Session", 1) .. "Session" },
        ["<Leader>ql"] = "resession.load_dir_cwd",
        ["<Leader>qL"] = "resession.load_last",
        ["<Leader>qs"] = "resession.save_dir",
        ["<Leader>qS"] = "resession.save",
        ["<Leader>qt"] = "resession.save_tab",
        ["<Leader>qf"] = "resession.load",
        ["<Leader>qF"] = "resession.load_dir",
        ["<Leader>qd"] = "resession.delete_dir",
        ["<Leader>qD"] = "resession.delete",
        ["<Leader>qq"] = { "<Cmd>confirm qall<CR>", desc = "Quit NeoVim" },

        ------------------
        -- Git integration
        ------------------

        ["[g"] = "gitsigns.prev_hunk",
        ["]g"] = "gitsigns.next_hunk",

        ["<Leader>g"] = { desc = icon("Git", 1) .. "Git" },
        ["<Leader>gs"] = "gitsigns.stage_hunk",
        ["<Leader>gS"] = "gitsigns.stage_buffer",
        ["<Leader>gr"] = "gitsigns.reset_hunk",
        ["<Leader>gR"] = "gitsigns.reset_buffer",
        ["<Leader>gu"] = "gitsigns.undo_stage_hunk",
        ["<Leader>gb"] = "gitsigns.show_blame",
        ["<Leader>gB"] = "gitsigns.show_full_blame",
        ["<Leader>gp"] = "gitsigns.show_hunk",
        ["<Leader>gP"] = "gitsigns.show_diff",
      },

      t = {
        ["<C-h>"] = "common.left_window",
        ["<C-j>"] = "common.down_window",
        ["<C-k>"] = "common.up_window",
        ["<C-l>"] = "common.right_window",
      },

      x = {
        ["j"] = "common.move_down",
        ["k"] = "common.move_up",
      },
    })
  end,
}
