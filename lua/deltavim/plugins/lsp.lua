local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

return {
  -- Lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "neoconf.nvim",
      "neodev.nvim",
      "cmp-nvim-lsp",
    },
    keys = function()
      return Keymap.Collector()
        :map({
          { "@ui.lsp_info", "<Cmd>LspInfo<CR>", "Lsp info" },
        })
        :collect_lazy()
    end,
    ---@class DeltaVim.Config.Lsp
    opts = {
      ---Options for `vim.diagnostic.config()`
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
        float = { border = Config.border },
      },
      ---Automatically format on save
      autoformat = true,
      ---Options for `vim.lsp.buf.format()`
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      ---LSP Server Settings
      ---@type lspconfig.options|table<string,table|boolean>
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
    },
    ---@param opts DeltaVim.Config.Lsp
    config = function(_, opts)
      local Lsp = require("deltavim.core.lsp")
      local servers = Util.copy_as_table(opts.servers)

      -- Setup autoformat and keymaps
      Lsp.AUTOFORMAT = opts.autoformat
      Util.on_lsp_attach(function(client, buffer)
        Lsp.autoformat(client, buffer, opts.format)
        Lsp.keymaps(client, buffer)
      end)

      -- Config diagnostics
      for name, icon in pairs(Config.icons.diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end
      vim.diagnostic.config(opts.diagnostics)

      -- Update capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      local function setup(server)
        local server_opts = Util.deep_merge({
          capabilities = capabilities,
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then return end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then return end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local has_mason = Util.has("mason-lspconfig.nvim")
      local available = Util.list_to_set(
        has_mason and require("mason-lspconfig").get_available_servers() or {}
      )

      ---@type string[]
      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        -- Run manual setup if `mason=false` or if this is a server that cannot
        -- be installed with mason-lspconfig
        if server_opts.mason == false or not available[server] then
          setup(server)
        else
          table.insert(ensure_installed, server)
        end
      end

      if has_mason then
        require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
        require("mason-lspconfig").setup_handlers({ setup })
      end

      -- Set LspInfo border
      require("lspconfig.ui.windows").default_options.border = Config.border
    end,
  },
  { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
  { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
  { "williamboman/mason-lspconfig.nvim", lazy = true, config = true },
  { "hrsh7th/cmp-nvim-lsp", cond = function() return Util.has("nvim-cmp") end },

  -- Formatters/linters
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = function()
      return Keymap.Collector()
        :map({
          { "@ui.nullls_info", "<Cmd>NullLsInfo<CR>", "Null-ls info" },
        })
        :collect_lazy()
    end,
    ---@class DeltaVim.Config.NullLs
    -- TODO: PR to LazyVim
    opts = {
      ---Null-ls formatters and options passed to `formatter:with(options)`.
      ---@type table<string,table|boolean>
      formatters = {
        fish_indent = true,
        shfmt = true,
        stylua = true,
      },
      ---Null-ls linters.
      ---@type table<string,table|boolean>
      linters = {
        fish = true,
        flake8 = true,
      },
      border = Config.border,
    },
    ---@param opts DeltaVim.Config.NullLs|table
    config = function(_, opts)
      local builtins = require("null-ls").builtins
      ---@type any[]
      local sources = Util.concat({}, opts.sources or {})
      for k, v in pairs(Util.copy_as_table(opts.formatters)) do
        table.insert(sources, builtins.formatting[k]:with(v))
      end
      for k, v in pairs(Util.copy_as_table(opts.linters)) do
        table.insert(sources, builtins.diagnostics[k]:with(v))
      end
      require("null-ls").setup(Util.merge({}, opts, { sources = sources }))
    end,
  },

  -- Install cmdline tools and lsp servers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = function()
      return Keymap.Collector()
        :map({
          { "@ui.mason", "<Cmd>Mason<CR>", "Mason" },
        })
        :collect_lazy()
    end,
    opts = {
      ensure_installed = {
        "flake8",
        "shfmt",
        "stylua",
      },
      ui = { border = Config.border },
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local registry = require("mason-registry")
      for _, name in ipairs(opts.ensure_installed) do
        local p = registry.get_package(name)
        if not p:is_installed() then p:install() end
      end
    end,
  },
}
