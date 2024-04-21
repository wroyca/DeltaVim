return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local astro, plug, map = require "astrocore", require "pde.utils.plug", opts.mappings
    local icon = require("astroui").get_icon

    if astro.is_available "alpha-nvim" then
      local alpha = plug.mappings "alpha"
      map.n["<Leader>h"] = alpha.show
    end

    if astro.is_available "neo-tree.nvim" then
      local neotree = plug.mappings "neo-tree"
      map.n["<Leader>e"] = neotree.toggle
    end

    -- UI/UX
    map.n["<Leader>u"] = { desc = icon("Window", 1) .. "UI/UX" }
    if astro.is_available "nvim-cmp" then
      local cmp = plug.mappings "cmp"
      map.n["<Leader>uc"] = cmp.toggle_buffer
      map.n["<Leader>uC"] = cmp.toggle_global
    end

    if astro.is_available "nvim-autopairs" then
      local autopairs = plug.mappings "autopairs"
      map.n["<Leader>ua"] = autopairs.toggle
    end

    -- session
    map.n["<Leader>q"] = { desc = icon("Session", 1) .. "Session" }
    map.n["<Leader>qq"] = { "<Cmd>confirm qall<CR>", desc = "Quit NeoVim" }
    if astro.is_available "resession.nvim" then
      local resession = plug.mappings "resession"
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
  end,
}
