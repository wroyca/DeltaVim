return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local astro, map = require "astrocore", opts.mappings

    if astro.is_available "alpha-nvim" then
      local alpha = require "pde.mappings.alpha"
      map.n["<Leader>h"] = alpha.show
    end

    if astro.is_available "neo-tree.nvim" then
      local neotree = require "pde.mappings.neo-tree"
      map.n["<Leader>e"] = neotree.toggle
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
  end,
}
