local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

M.AUTOFORMAT = true
M.FORMAT_OPTS = {}

---@param buffer integer
function M.format(buffer)
  local use_nls = Util.nls_supports(vim.bo[buffer].ft, "FORMATTING")
  vim.lsp.buf.format(Util.deep_merge({
    bufnr = buffer,
    filter = function(client)
      if use_nls then return client.name == "null-ls" end
      return client.name ~= "null-ls"
    end,
  }, M.FORMAT_OPTS or {}))
end

function M.toggle_autoformat() M.AUTOFORMAT = not M.AUTOFORMAT end

---@param client table
---@param buffer integer
function M.autoformat(client, buffer)
  -- Don't format if client disabled it
  if
    client.config
    and client.config.capabilities
    and client.config.capabilities["documentFormattingProvider"] == false
  then
    return
  end

  if
    client.name == "null-ls"
      and Util.nls_supports(vim.bo[buffer].ft, "FORMATTING")
    or client.name ~= "null-ls"
      and client.server_capabilities["documentFormattingProvider"]
  then
    vim.b[buffer]["deltavim.config.autocmds.trim_whitespace"] = false
    Util.autocmd("BufWritePre", function()
      if M.AUTOFORMAT then M.format(buffer) end
    end, { buffer = buffer })
  end
end

---@type DeltaVim.Keymap.Output[]
local KEYMAPS

---@param client table
---@param buffer integer
function M.keymaps(client, buffer)
  ---@param cmd string
  ---@param has string
  ---@param opts? table
  local function lsp(cmd, has, opts)
    if opts == nil then
      return { vim.lsp.buf[cmd], has }
    else
      return { function() vim.lsp.buf[cmd](opts) end, has }
    end
  end

  ---@param next boolean
  ---@param level? string
  local function goto_diagnostic(next, level)
    local f = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    local severity = level and vim.diagnostic.severity[level] or nil
    return { function() f({ severity = severity }) end }
  end

  local code_action_source = lsp("code_action", "codeAction", {
    context = {
      only = {
        "source",
      },
      diagnostics = {},
    },
  })

  local function format() M.format(buffer) end

  -- stylua: ignore
  KEYMAPS = KEYMAPS or Keymap.Collector()
    :map({
      -- lsp
      { "@lsp.code_action", lsp("code_action", "codeAction"), "Code action", mode = { "*", "x" } },
      { "@lsp.code_action_source", code_action_source, "Source action", mode = { "*", "x" } },
      { "@lsp.declaration", lsp("declaration", "declaration"), "Declaration" },
      { "@lsp.definitions", lsp("definition", "definition"), "Definitions" },
      { "@lsp.format", { format, "documentFormatting" }, "Format document", mode = "*" },
      { "@lsp.format", { format, "documentRangeFormatting" }, "Format range", mode = "x" },
      { "@lsp.hover", lsp("hover", "hover"), "Hover" },
      { "@lsp.implementations", lsp("implementation", "implementation"), "Implementations" },
      { "@lsp.line_diagnostics", { vim.diagnostic.open_float }, "Line diagnostics" },
      { "@lsp.references", lsp("references", "references"), "References" },
      { "@lsp.rename", lsp("rename", "rename"), "Rename" },
      { "@lsp.signature_help",  lsp("signature_help", "signatureHelp") , "Signature help" },
      { "@lsp.type_definitions", lsp("type_definition", "typeDefinition"), "Type definitions" },
      -- goto
      { "@goto.next_diagnostic", goto_diagnostic(true), "Next diagnostic" },
      { "@goto.prev_diagnostic", goto_diagnostic(false), "Prev diagnostic" },
      { "@goto.next_error", goto_diagnostic(true, "ERROR"), "Next error" },
      { "@goto.prev_error", goto_diagnostic(false, "ERROR"), "Prev error" },
      { "@goto.next_warning", goto_diagnostic(true, "WARN"), "Next warning" },
      { "@goto.prev_warning", goto_diagnostic(false, "WARN"), "Prev warning" },
    })
    :collect()

  M.set_keymaps(client, buffer, KEYMAPS)
end

---Set keymaps only server has specified capabilities.
---@param client table
---@param keymaps DeltaVim.Keymap.Output[]
function M.set_keymaps(client, buffer, keymaps)
  for _, m in ipairs(keymaps) do
    local rhs, has
    if type(m[2]) == "table" then
      rhs, has = unpack(m[2])
    else
      rhs = m[2]
    end
    if not has or client.server_capabilities[has .. "Provider"] then
      Util.keymap(m.mode, m[1], rhs, Util.merge({ buffer = buffer }, m.opts))
    end
  end
end

return M
