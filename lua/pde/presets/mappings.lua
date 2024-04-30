return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local utils, icon = require "pde.utils", require("astroui").get_icon
    local map = opts.mappings

    -- enhancement
    map.x["<"] = { "<gv" }
    map.x[">"] = { ">gv" }
    map.n["<Esc>"] = { "<Cmd>noh<CR><Esc>" }
    map.n["gw"] = { "*N", noremap = true }

    utils.make_mappings(map, {
      ------------------
      -- common mappings
      ------------------

      ["common"] = {
        n = {
          ["j"] = "move_down",
          ["k"] = "move_up",
          ["gx"] = "system_open",

          ["<C-h>"] = "left_window",
          ["<C-j>"] = "down_window",
          ["<C-k>"] = "up_window",
          ["<C-l>"] = "right_window",
          ["<C-s>"] = "save_file",
          ["<C-S-h>"] = "resize_left",
          ["<C-S-j>"] = "resize_down",
          ["<C-S-k>"] = "resize_up",
          ["<C-S-l>"] = "resize_right",

          ["<Leader>n"] = "new_file",
          ["<Leader>W"] = "close_window",
          ["<Leader>-"] = "hsplit",
          ["<Leader>\\"] = "vsplit",
        },

        t = {
          ["<C-h>"] = "left_window",
          ["<C-j>"] = "down_window",
          ["<C-k>"] = "up_window",
          ["<C-l>"] = "right_window",
        },

        x = {
          ["j"] = "move_down",
          ["k"] = "move_up",
        },
      },

      --------------------
      -- package management
      --------------------

      ["lazy"] = {
        n = {
          ["<Leader>p"] = { desc = icon("Package", 1) .. "Packages" },

          ["<Leader>pc"] = "check",
          ["<Leader>pi"] = "install",
          ["<Leader>pp"] = "show_status",
          ["<Leader>ps"] = "sync",
          ["<Leader>pu"] = "update",
        },
      },

      --------------------
      -- editor components
      --------------------

      ["alpha"] = { n = { ["<Leader>h"] = "show" } },
      ["neo-tree"] = { n = { ["<Leader>e"] = "focus" } },

      ------------------
      -- editor features
      ------------------

      ["toggles"] = {
        n = {
          ["<Leader>u"] = { desc = icon("Setting", 1) .. "UI/UX" },

          ["<Leader>ub"] = "toggle_background",
          ["<Leader>ud"] = "toggle_diagnostics",
          ["<Leader>ug"] = "toggle_signcolumn",
          ["<Leader>ui"] = "toggle_indent",
          ["<Leader>ul"] = "toggle_statusline",
          ["<Leader>un"] = "toggle_number",
          ["<Leader>up"] = "toggle_paste",
          ["<Leader>us"] = "toggle_spell",
          ["<Leader>ut"] = "toggle_tabline",
          ["<Leader>uu"] = "toggle_url_match",
          ["<Leader>uw"] = "toggle_wrap",
          ["<Leader>uy"] = "toggle_syntax",
          ["<Leader>uz"] = "toggle_foldcolumn",
          ["<Leader>uA"] = "toggle_autochdir",
          ["<Leader>uN"] = "toggle_notifications",
          ["<Leader>uS"] = "toggle_conceal",
        },
      },

      ["cmp"] = {
        n = {
          ["<Leader>uc"] = "toggle_buffer",
          ["<Leader>uC"] = "toggle_global",
        },
      },

      ["autopairs"] = {
        n = {
          ["<Leader>ua"] = "toggle",
        },
      },

      --------------------
      -- buffer management
      --------------------

      ["buffer"] = {
        n = {
          ["<Leader>b"] = { desc = icon("Tab", 1) .. "Buffers" },
          ["<Leader>bs"] = { desc = icon("Sort", 1) .. "Sort buffers" },
          ["<Leader>t"] = { desc = icon("Window", 1) .. "Tabs" },

          ["[b"] = "prev",
          ["]b"] = "next",
          ["<C-,>"] = "prev",
          ["<C-.>"] = "next",
          ["<b"] = "move_left",
          [">b"] = "move_right",

          ["<Leader>w"] = "close",
          ["<Leader>bc"] = "close_others",
          ["<Leader>bC"] = "close_all",
          ["<Leader>bh"] = "close_left",
          ["<Leader>bl"] = "close_right",

          ["<Leader>bse"] = "sort_by_extension",
          ["<Leader>bsf"] = "sort_by_filename",
          ["<Leader>bsp"] = "sort_by_path",
          ["<Leader>bsn"] = "sort_by_number",
          ["<Leader>bsm"] = "sort_by_modification",

          ["[t"] = "prev_tab",
          ["]t"] = "next_tab",
          ["<Leader>tn"] = "new_tab",
          ["<Leader>tc"] = "close_tab",
          ["<Leader>th"] = "first_tab",
          ["<Leader>tl"] = "last_tab",
        },
      },

      ["heirline"] = {
        n = {
          ["<Leader>bb"] = "pick_select",
          ["<Leader>bd"] = "pick_close",
          ["<Leader>b\\"] = "pick_hsplit",
          ["<Leader>b-"] = "pick_vsplit",
        },
      },

      ---------------------
      -- session management
      ---------------------

      ["resession"] = {
        n = {
          ["<Leader>q"] = { desc = icon("Session", 1) .. "Session" },

          ["<Leader>ql"] = "load_dir_cwd",
          ["<Leader>qL"] = "load_last",
          ["<Leader>qs"] = "save_dir",
          ["<Leader>qS"] = "save",
          ["<Leader>qt"] = "save_tab",
          ["<Leader>qf"] = "load",
          ["<Leader>qF"] = "load_dir",
          ["<Leader>qd"] = "delete_dir",
          ["<Leader>qD"] = "delete",
          ["<Leader>qq"] = { "<Cmd>confirm qall<CR>", desc = "Quit NeoVim" },
        },
      },

      ------------------
      -- Git integration
      ------------------

      ["gitsigns"] = {
        n = {
          ["[g"] = "prev_hunk",
          ["]g"] = "next_hunk",

          ["<Leader>g"] = { desc = icon("Git", 1) .. "Git" },
          ["<Leader>gs"] = "stage_hunk",
          ["<Leader>gS"] = "stage_buffer",
          ["<Leader>gr"] = "reset_hunk",
          ["<Leader>gR"] = "reset_buffer",
          ["<Leader>gu"] = "undo_stage_hunk",
          ["<Leader>gb"] = "show_blame",
          ["<Leader>gB"] = "show_full_blame",
          ["<Leader>gp"] = "show_hunk",
          ["<Leader>gP"] = "show_diff",
        },
      },
    })
  end,
}
