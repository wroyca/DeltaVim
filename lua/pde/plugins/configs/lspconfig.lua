return function(_, _)
  vim.tbl_map(require("astrolsp").lsp_setup, require("astrolsp").config.servers)
  require("astrocore").exec_buffer_autocmds("FileType", { group = "lspconfig" })
  require("astrocore").event "LspSetup"
end
