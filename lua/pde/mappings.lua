return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local astro, map = require "astrocore", opts.mappings
    local icon = require("astroui").get_icon

    if astro.is_available "alpha-nvim" then
      local alpha = require "pde.mappings.alpha"
      map.n["<Leader>h"] = alpha.show
    end

    if astro.is_available "neo-tree.nvim" then
      local neotree = require "pde.mappings.neo-tree"
      map.n["<Leader>e"] = neotree.toggle
    end

    -- UI/UX
    map.n["<Leader>u"] = { desc = (icon "Window") .. "UI/UX" }
    if astro.is_available "nvim-cmp" then
      local cmp = require "pde.mappings.cmp"
      map.n["<Leader>uc"] = cmp.toggle_buffer
      map.n["<Leader>uC"] = cmp.toggle_global
    end

    if astro.is_available "nvim-autopairs" then
      local autopairs = require "pde.mappings.autopairs"
      map.n["<Leader>ua"] = autopairs.toggle
    end

    -- session
    map.n["<Leader>q"] = { desc = (icon "Session") .. "Session" }
    map.n["<Leader>qq"] = { "<Cmd>confirm qall<CR>", desc = "Quit NeoVim" }
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
  end,
}
