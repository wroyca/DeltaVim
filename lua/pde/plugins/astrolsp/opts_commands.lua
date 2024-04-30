return {
  Format = {
    cond = require("pde.utils").formatting_enabled,
    function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
    desc = "Format file with LSP",
  },
}
