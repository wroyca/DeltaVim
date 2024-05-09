return function(_, opts)
  require("nvim-ts-autotag").setup(opts)
  require("astrocore").exec_buffer_autocmds("FileType", { group = "nvim_ts_xmltag" })
  vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
      update_in_insert = true,
    })
end
