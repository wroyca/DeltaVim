return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local astro, map, icon = require "astrocore", opts.mappings, require("astroui").get_icon

    ------------------
    -- common mappings
    ------------------

    -- enhancement
    map.x["<"] = { "<gv" }
    map.x[">"] = { ">gv" }
    map.n["<Esc>"] = { "<Cmd>noh<CR><Esc>" }
    map.n["gw"] = { "*N", noremap = true }

    do
      local common = require "pde.mappings.common"
      map.n["j"] = common.move_down
      map.x["j"] = common.move_down
      map.n["k"] = common.move_up
      map.x["k"] = common.move_up

      map.n["<Leader>n"] = common.new_file
      map.n["<C-s>"] = common.save_file

      map.n["<Leader>\\"] = common.vsplit
      map.n["<Leader>-"] = common.hsplit
      map.n["<Leader>W"] = common.close_window

      map.n["gx"] = common.system_open

      map.n["<C-h>"] = common.left_window
      map.n["<C-j>"] = common.down_window
      map.n["<C-k>"] = common.up_window
      map.n["<C-l>"] = common.right_window

      map.t["<C-h>"] = common.left_window
      map.t["<C-j>"] = common.down_window
      map.t["<C-k>"] = common.up_window
      map.t["<C-l>"] = common.right_window

      map.n["<C-S-h>"] = common.resize_left
      map.n["<C-S-j>"] = common.resize_down
      map.n["<C-S-k>"] = common.resize_up
      map.n["<C-S-l>"] = common.resize_right
    end

    --------------------
    -- editor components
    --------------------

    if astro.is_available "alpha-nvim" then
      local alpha = require "pde.mappings.alpha"
      map.n["<Leader>h"] = alpha.show
    end

    if astro.is_available "neo-tree.nvim" then
      local neotree = require "pde.mappings.neo-tree"
      map.n["<Leader>e"] = neotree.focus
    end

    --------------------
    -- package management
    --------------------
    map.n["<Leader>p"] = { desc = icon("Package", 1) .. "Packages" }

    do
      local lazy = require "pde.mappings.lazy"
      map.n["<Leader>pc"] = lazy.check
      map.n["<Leader>pi"] = lazy.install
      map.n["<Leader>pp"] = lazy.show_status
      map.n["<Leader>ps"] = lazy.sync
      map.n["<Leader>pu"] = lazy.update
    end

    -----------------------
    -- buffer management --
    -----------------------
    map.n["<Leader>b"] = { desc = icon("Tab", 1) .. "Buffers" }
    map.n["<Leader>bs"] = { desc = icon("Sort", 1) .. "Sort buffers" }
    map.n["<Leader>t"] = { desc = icon("Window", 1) .. "Tabs" }

    do
      local buf = require "pde.mappings.buffer"
      map.n["[b"] = buf.prev
      map.n["]b"] = buf.next
      map.n["<C-,>"] = buf.prev
      map.n["<C-.>"] = buf.next
      map.n["<b"] = buf.move_left
      map.n[">b"] = buf.move_right

      map.n["<Leader>w"] = buf.close
      map.n["<Leader>bc"] = buf.close_others
      map.n["<Leader>bC"] = buf.close_all
      map.n["<Leader>bh"] = buf.close_left
      map.n["<Leader>bl"] = buf.close_right

      map.n["<Leader>bse"] = buf.sort_by_extension
      map.n["<Leader>bsf"] = buf.sort_by_filename
      map.n["<Leader>bsp"] = buf.sort_by_path
      map.n["<Leader>bsn"] = buf.sort_by_number
      map.n["<Leader>bsm"] = buf.sort_by_modification

      map.n["[t"] = buf.prev_tab
      map.n["]t"] = buf.next_tab
      map.n["<Leader>tn"] = buf.new_tab
      map.n["<Leader>tc"] = buf.close_tab
      map.n["<Leader>th"] = buf.first_tab
      map.n["<Leader>tl"] = buf.last_tab
    end

    ------------------------
    -- toggle UI/UX features
    ------------------------
    map.n["<Leader>u"] = { desc = icon("Setting", 1) .. "UI/UX" }

    do
      local ui = require "pde.mappings.ui"
      map.n["<Leader>ub"] = ui.toggle_background
      map.n["<Leader>ud"] = ui.toggle_diagnostics
      map.n["<Leader>ug"] = ui.toggle_signcolumn
      map.n["<Leader>ui"] = ui.toggle_indent
      map.n["<Leader>ul"] = ui.toggle_statusline
      map.n["<Leader>un"] = ui.toggle_number
      map.n["<Leader>up"] = ui.toggle_paste
      map.n["<Leader>us"] = ui.toggle_spell
      map.n["<Leader>ut"] = ui.toggle_tabline
      map.n["<Leader>uu"] = ui.toggle_url_match
      map.n["<Leader>uw"] = ui.toggle_wrap
      map.n["<Leader>uy"] = ui.toggle_buffer_syntax
      map.n["<Leader>uz"] = ui.toggle_foldcolumn
      map.n["<Leader>uA"] = ui.toggle_autochdir
      map.n["<Leader>uN"] = ui.toggle_notifications
      map.n["<Leader>uS"] = ui.toggle_conceal
    end

    if astro.is_available "nvim-cmp" then
      local cmp = require "pde.mappings.cmp"
      map.n["<Leader>uc"] = cmp.toggle_buffer
      map.n["<Leader>uC"] = cmp.toggle_global
    end

    if astro.is_available "nvim-autopairs" then
      local autopairs = require "pde.mappings.autopairs"
      map.n["<Leader>ua"] = autopairs.toggle
    end

    ----------
    -- session
    ----------
    map.n["<Leader>q"] = { desc = icon("Session", 1) .. "Session" }

    if astro.is_available "resession.nvim" then
      local resession = require "pde.mappings.resession"
      map.n["<Leader>ql"] = resession.load_dir_cwd
      map.n["<Leader>qL"] = resession.load_last
      map.n["<Leader>qs"] = resession.save_dir
      map.n["<Leader>qS"] = resession.save
      map.n["<Leader>qt"] = resession.save_tab
      map.n["<Leader>qf"] = resession.load
      map.n["<Leader>qF"] = resession.load_dir
      map.n["<Leader>qd"] = resession.delete_dir
      map.n["<Leader>qD"] = resession.delete
    end
    map.n["<Leader>qq"] = { "<Cmd>confirm qall<CR>", desc = "Quit NeoVim" }

    ------
    -- Git
    ------
    map.n["<Leader>g"] = { desc = icon("Git", 1) .. "Git" }

    if astro.is_available "gitsigns.nvim" then
      local git = require "pde.mappings.gitsigns"
      map.n["[g"] = git.prev_hunk
      map.n["]g"] = git.next_hunk
      map.n["<Leader>gs"] = git.stage_hunk
      map.n["<Leader>gS"] = git.stage_buffer
      map.n["<Leader>gr"] = git.reset_hunk
      map.n["<Leader>gR"] = git.reset_buffer
      map.n["<Leader>gu"] = git.undo_stage_hunk
      map.n["<Leader>gb"] = git.show_blame
      map.n["<Leader>gB"] = git.show_full_blame
      map.n["<Leader>gp"] = git.show_hunk
      map.n["<Leader>gP"] = git.show_diff
    end
  end,
}
