local M = {}

---@class DeltaVim.Config
local CONFIG = {
  ---@type string|fun()
  colorscheme = function() require("tokyonight").load() end,
  icons = {
    diagnostics = {
      Error = " ",
      Warn = " ",
      Hint = " ",
      Info = " ",
    },
    git = {
      added = " ",
      modified = " ",
      removed = " ",
    },
    kinds = {
      Array = " ",
      Boolean = " ",
      Class = " ",
      Color = " ",
      Constant = " ",
      Constructor = " ",
      Enum = " ",
      EnumMember = " ",
      Event = " ",
      Field = " ",
      File = " ",
      Folder = " ",
      Function = " ",
      Interface = " ",
      Key = " ",
      Keyword = " ",
      Method = " ",
      Module = " ",
      Namespace = " ",
      Null = "ﳠ ",
      Number = " ",
      Object = " ",
      Operator = " ",
      Package = " ",
      Property = " ",
      Reference = " ",
      Snippet = " ",
      String = " ",
      Struct = " ",
      Text = " ",
      TypeParameter = " ",
      Unit = " ",
      Value = " ",
      Variable = " ",
    },
  },
  lsp = {
    ---Options for `vim.diagnostic.config()`
    diagnostics = {
      underline = true,
      update_in_insert = false,
      virtual_text = { spacing = 4, prefix = "●" },
      severity_sort = true,
    },
    ---Automatically format on save
    autoformat = true,
    ---Options for `vim.lsp.buf.format()`
    format = {
      formatting_options = nil,
      timeout_ms = nil,
    },
    ---LSP Server Settings
    ---@type lspconfig.options|table<string,boolean>
    servers = {
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
    },
    ---Additional lsp server setup.
    ---Return true to disable the setup of `lspconfig`.
    ---Specify `*` to use this function as a fallback for any server
    ---@type table<string,fun(server:string,opts:table):boolean?>
    setup = {},
    ---Null-ls formatters and options passed to `formatter:with(options)`.
    ---@type table<string,table>
    formatters = {
      stylua = {},
    },
    ---Null-ls linters.
    ---@type table<string,table|boolean>
    linters = {
      flake8 = {},
    },
  },
  keymap_groups = {
    mode = { "n", "x" },
    ["g"] = { name = "+goto" },
    ["gz"] = { name = "+surround" },
    ["]"] = { name = "+next" },
    ["["] = { name = "+prev" },
    ["<leader><tab>"] = { name = "+tabs" },
    ["<leader>b"] = { name = "+buffer" },
    ["<leader>c"] = { name = "+code" },
    ["<leader>f"] = { name = "+file/find" },
    ["<leader>g"] = { name = "+git" },
    ["<leader>gh"] = { name = "+hunks" },
    ["<leader>q"] = { name = "+quit/session" },
    ["<leader>s"] = { name = "+search" },
    ["<leader>u"] = { name = "+ui" },
    ["<leader>w"] = { name = "+windows" },
    ["<leader>x"] = { name = "+diagnostics/quickfix" },
    ["<leader>sn"] = { name = "+noice" },
  },
}

---@cast M +DeltaVim.Config
setmetatable(M, { __index = CONFIG })

---@param cfg DeltaVim.Config
function M.update(cfg) CONFIG = cfg end

return M
