return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local astro, map = require "astrocore", opts.mappings

    if astro.is_available "alpha-nvim" then
      map.n["<Leader>h"] = require("pde.mappings.alpha").show
    end

    if astro.is_available "neo-tree.nvim" then
      map.n["<Leader>e"] = require("pde.mappings.neo-tree").toggle
    end
  end,
}
