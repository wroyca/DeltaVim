return function(_, opts)
  local npairs, astro = require "nvim-autopairs", require "astrocore"
  npairs.setup(opts)

  if not astro.config.features.autopairs then npairs.disable() end
  astro.on_load(
    "nvim-cmp",
    function()
      require("cmp").event:on(
        "confirm_done",
        require("nvim-autopairs.completion.cmp").on_confirm_done { tex = false }
      )
    end
  )
end
