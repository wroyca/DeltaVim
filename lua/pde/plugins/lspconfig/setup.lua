return function(_, _)
  -- set border
  require("lspconfig.ui.windows").default_options.border = require("pde").get_border "float_border"
  vim.tbl_map(require("astrolsp").lsp_setup, require("astrolsp").config.servers)
  require("astrocore").exec_buffer_autocmds("FileType", { group = "lspconfig" })
  require("astrocore").event "LspSetup"
end
