local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

M.AUTOFORMAT = true

---@param buffer integer
---@param opts? table
function M.format(buffer, opts)
  local ft = vim.bo[buffer].filetype
  local methods = require("null-ls.methods").internal
  -- stylua: ignore
  local use_nls = #require("null-ls.sources").get_available(ft, methods.FORMATTING) > 0
  vim.lsp.buf.format(Util.deep_merge({
    bufnr = buffer,
    filter = function(client)
      if use_nls then return client.name == "null-ls" end
      return client.name ~= "null-ls"
    end,
  }, opts or {}))
end

function M.toggle_autoformat() M.AUTOFORMAT = not M.AUTOFORMAT end

---@param client any
---@param buffer integer
---@param opts? table
function M.autoformat(client, buffer, opts)
  if
    M.AUTOFORMAT
    -- Don't format if client disabled it
    and client.config
    and client.config.capabilities
    and client.config.capabilities["documentFormattingProvider"] == false
  then
    return
  end

  if client.server_capabilities["documentFormattingProvider"] then
    Util.autocmd(
      "BufWritePre",
      function() M.format(buffer, opts) end,
      { buffer = buffer }
    )
  end
end

---@type DeltaVim.Keymap.Output[]
local KEYMAPS

---@param client any
---@param buffer integer
function M.keymaps(client, buffer)
  ---@param cmd string
  ---@param has string
  local function lsp(cmd, has) return { vim.lsp.buf[cmd], has } end

  ---@param next boolean
  ---@param level? string
  local function goto_diagnostic(next, level)
    local f = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    local severity = level and vim.diagnostic.severity[level] or nil
    return { function() f({ severity = severity }) end }
  end

  -- stylua: ignore
  KEYMAPS = KEYMAPS or Keymap.Collector()
    :map({
      -- lsp
      { "@lsp.code_action", lsp("code_action", "codeAction"), "Code action", mode = { "*", "x" } },
      { "@lsp.declaration", lsp("declaration", "declaration"), "Declaration" },
      { "@lsp.definitions", lsp("definition", "definition"), "Definitions" },
      { "@lsp.format", { M.format, "documentFormatting" }, "Format document", mode = "*" },
      { "@lsp.format", { M.format, "documentRangeFormatting" }, "Format range", mode = "x" },
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

  for _, m in ipairs(KEYMAPS) do
    local rhs, has = unpack(m[2])
    if not has or client.server_capabilities[has .. "Provider"] then
      Util.keymap(m.mode, m[1], rhs, Util.merge({ buffer = buffer }, m.opts))
    end
  end
end

return M
