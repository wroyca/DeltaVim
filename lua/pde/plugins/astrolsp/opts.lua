---@type AstroLSPOpts
return {
  autocmds = require "pde.plugins.astrolsp.opts_autocmds",
  commands = require "pde.plugins.astrolsp.opts_commands",
  features = {
    codelens = true,
    inlay_hints = false,
    lsp_handlers = true,
    semantic_tokens = true,
  },
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  ---@diagnostic disable-next-line: missing-fields
  config = {
    lua_ls = {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
        },
      },
    },
  },
  flags = {},
  formatting = {
    format_on_save = { enabled = true },
    disabled = {},
  },
  handlers = {
    function(server, opts) require("lspconfig")[server].setup(opts) end,
  },
  lsp_handlers = {
    ["textDocument/hover"] = vim.lsp.with(
      vim.lsp.handlers.hover,
      { border = "none", silent = true }
    ),
    ["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      { border = "none", silent = true }
    ),
  },
  servers = { "lua_ls" },
  on_attach = nil,
}
