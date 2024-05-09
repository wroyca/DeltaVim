return {
  delay = 200,
  min_count_to_highlight = 2,
  large_file_overrides = { providers = { "lsp" } },
  should_enable = function(bufnr) return require("astrocore.buffer").is_valid(bufnr) end,
}
