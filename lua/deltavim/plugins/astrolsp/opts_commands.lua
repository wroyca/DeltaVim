return {
  Format = {
    cond = require("deltavim.utils").formatting_enabled,
    function() vim.lsp.buf.format(require("astrolsp").format_opts) end,
    desc = "Format file with LSP",
  },
}
