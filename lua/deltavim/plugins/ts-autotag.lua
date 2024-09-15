---@module "nvim-ts-autotag"

---@type LazyPluginSpec
return {
  "windwp/nvim-ts-autotag",
  event = "User AstroFile",
  dependencies = { "nvim-treesitter" },
  config = function(_, opts)
    require("nvim-ts-autotag").setup(opts)
    require("astrocore").exec_buffer_autocmds("FileType", { group = "nvim_ts_xmltag" })
    -- enable update in insert
    -- Credit: https://github.com/windwp/nvim-ts-autotag/blob/531f483/README.md?plain=1#L57-L69
    vim.lsp.handlers["textDocument/publishDiagnostics"] =
      vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = true,
      })
  end,
}
