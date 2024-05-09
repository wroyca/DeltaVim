---@type AstroLSPOpts
return {
  autocmds = require "deltavim.plugins.astrolsp.opts_autocmds",
  commands = require "deltavim.plugins.astrolsp.opts_commands",
  mappings = require("astrocore").empty_map_table(),
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
    disabled = { "lua_ls" },
  },
  handlers = {
    function(server, opts) require("lspconfig")[server].setup(opts) end,
  },
  lsp_handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = require("deltavim").get_border "popup_border",
      silent = true,
    }),
    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
      border = require("deltavim").get_border "popup_border",
      silent = true,
    }),
  },
  servers = { "lua_ls" },
  ---@type table<string,boolean|table> setup null-ls formatters
  formatters = {
    stylua = true,
  },
  ---@type table<string,boolean|table> setup null-ls linters
  linters = {},
  on_attach = nil,
}
