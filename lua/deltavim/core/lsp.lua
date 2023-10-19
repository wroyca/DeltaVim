local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

M.FORMAT_OPTS = {}

---@param buffer? integer
function M.format(buffer)
  buffer = buffer or 0
  local use_nls = M.nls_supports(buffer, "formatting")
  vim.lsp.buf.format(Util.deep_merge({
    bufnr = buffer,
    filter = function(client)
      return use_nls and client.name == "null-ls" or not use_nls and client.name ~= "null-ls"
    end,
  }, M.FORMAT_OPTS or {}))
end

function M.toggle_autoformat()
  vim.g.autoformat = not vim.g.autoformat
end

---@param client table
---@param buffer integer
function M.autoformat(client, buffer)
  -- Don't format if client disabled it
  if
    client.config and client.config.capabilities and client.config.capabilities["documentFormattingProvider"] == false
    or not client.supports_method("textDocument/formatting")
  then
    return
  end

  vim.b[buffer]["deltavim.config.autocmds.trim_whitespace"] = false
  Util.autocmd("BufWritePre", function()
    if vim.g.autoformat then
      M.format(buffer)
    end
  end, { buffer = buffer })
end

---@type DeltaVim.Keymap.Output[]
local KEYMAPS

local function make_keymaps()
  ---@param cmd string
  ---@param opts? table
  local function lsp(cmd, opts)
    if opts == nil then
      return vim.lsp.buf[cmd]
    else
      return function()
        vim.lsp.buf[cmd](opts)
      end
    end
  end

  ---@param next boolean
  ---@param level? string
  local function goto_diagnostic(next, level)
    local f = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    local severity = level and vim.diagnostic.severity[level] or nil
    return function()
      f({ severity = severity })
    end
  end

  local code_action_source = lsp("code_action", { context = { only = { "source" }, diagnostics = {} } })

  ---@param level? string
  local function diagnostics(level)
    local severity = level and vim.diagnostic.severity[level] or nil
    return function()
      vim.diagnostic.open_float({ severity = severity })
    end
  end

  return Keymap.Collector()
    :map({
      -- lsp
      { "@lsp.code_action", lsp("code_action"), "Code action", mode = { "*", "x" } },
      { "@lsp.code_action_source", code_action_source, "Source action", mode = { "*", "x" } },
      { "@lsp.declaration", lsp("declaration"), "Declaration" },
      { "@lsp.definitions", lsp("definition"), "Definitions" },
      { "@lsp.format", M.format, "Format document", mode = "*" },
      { "@lsp.format", M.format, "Format range", mode = "x" },
      { "@lsp.hover", lsp("hover"), "Hover" },
      { "@lsp.implementations", lsp("implementation"), "Implementations" },
      { "@lsp.line_diagnostics", diagnostics(), "Line diagnostics" },
      { "@lsp.line_errors", diagnostics("E"), "Line errors" },
      { "@lsp.line_warnings", diagnostics("W"), "Line warnings" },
      { "@lsp.references", lsp("references"), "References" },
      { "@lsp.rename", lsp("rename"), "Rename" },
      { "@lsp.signature_help", lsp("signature_help"), "Signature help" },
      { "@lsp.type_definitions", lsp("type_definition"), "Type definitions" },
      -- goto
      { "@goto.next_diagnostic", goto_diagnostic(true), "Next diagnostic" },
      { "@goto.prev_diagnostic", goto_diagnostic(false), "Prev diagnostic" },
      { "@goto.next_error", goto_diagnostic(true, "E"), "Next error" },
      { "@goto.prev_error", goto_diagnostic(false, "E"), "Prev error" },
      { "@goto.next_warning", goto_diagnostic(true, "W"), "Next warning" },
      { "@goto.prev_warning", goto_diagnostic(false, "W"), "Prev warning" },
    })
    :collect()
end

---@param buffer integer
function M.keymaps(_, buffer)
  KEYMAPS = KEYMAPS or make_keymaps()
  for _, m in ipairs(KEYMAPS) do
    Util.keymap(m.mode, m[1], m[2], Util.merge({ buffer = buffer }, m.opts))
  end
end

local CAPABILITY_MAP = {
  codeAction = "CODE_ACTION",
  completion = "COMPLETION",
  diagnostics = "DIAGNOSTICS",
  formatting = "FORMATTING",
  rangeFormatting = "RANGE_FORMATTING",
  hover = "HOVER",
}

---@param buffer integer
---@param method string
---@return boolean
function M.nls_supports(buffer, method)
  return CAPABILITY_MAP[method] ~= nil
    and package.loaded["null-ls"]
    and #require("null-ls.sources").get_available(
        vim.bo[buffer].ft,
        require("null-ls").methods[CAPABILITY_MAP[method]]
      )
      > 0
end

---@param server string
---@return table?
function M.get_config(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

---Disable a lsp server before setup.
---@param server string
---@param cond fun(config:table,root:string): boolean
function M.disable(server, cond)
  local util = require("lspconfig.util")
  local def = M.lsp_get_config(server)
  def.document_config.on_new_config = util.add_hook_before(def.document_config.on_new_config, function(config, root)
    if cond(config, root) then
      config.enabled = false
    end
  end)
end

return M
