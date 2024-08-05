---@type LazyPluginSpec
return {
  "RRethy/vim-illuminate",
  event = "User AstroFile",
  opts = function()
    return {
      delay = 200,
      large_file_cutoff = require("astrocore").config.features.large_buf.lines,
      min_count_to_highlight = 2,
      large_file_overrides = { providers = { "lsp" } },
      should_enable = function(bufnr)
        return require("astrocore.buffer").is_valid(bufnr) and not vim.b[bufnr].large_buf
      end,
    }
  end,
  config = function(_, opts) require("illuminate").configure(opts) end,
}
