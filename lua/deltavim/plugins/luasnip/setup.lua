return function(_, opts)
  require("luasnip").config.setup(opts or {})
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip.loaders.from_snipmate").lazy_load()
  require("luasnip.loaders.from_lua").lazy_load()
end
