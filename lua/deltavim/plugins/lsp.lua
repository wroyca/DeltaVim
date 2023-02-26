local Config = require("deltavim.config")
local Lsp = require("deltavim.core.lsp")
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
      "mason.nvim",
      "mason-lspconfig.nvim",
      "cmp-nvim-lsp",
    },
    keys = function()
      return Keymap.Collector()
        :map({
          { "@ui.lsp_info", "<Cmd>LspInfo<CR>", "Lsp info" },
        })
        :collect_lazy()
    end,
    config = function()
      local opts = Config.lsp
      local servers = Util.copy_as_table(opts.servers)

      -- Setup autoformat and keymaps
      Util.on_lsp_attach(function(client, buffer)
        Lsp.autoformat(client, buffer)
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

      -- Temp fix for lspconfig rename
      -- https://github.com/neovim/nvim-lspconfig/pull/2439
      -- TODO: remove this patch
      local mappings = require("mason-lspconfig.mappings.server")
      if not mappings.lspconfig_to_package.lua_ls then
        mappings.lspconfig_to_package.lua_ls = "lua-language-server"
        mappings.package_to_lspconfig["lua-language-server"] = "lua_ls"
      end

      local mlsp = require("mason-lspconfig")
      local available = mlsp.get_available_servers()

      ---@type string[]
      local ensure_installed = {}
      for server, server_opts in pairs(servers) do
        -- Run manual setup if `mason=false` or if this is a server that cannot
        -- be installed with mason-lspconfig
        if
          server_opts.mason == false
          or not vim.tbl_contains(available, server)
        then
          setup(server)
        else
          table.insert(ensure_installed, server)
        end
      end

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({ setup })
    end,
  },
  { "folke/neoconf.nvim", cmd = "Neoconf", opts = {} },
  { "folke/neodev.nvim", opts = { experimental = { pathStrict = true } } },
  { "williamboman/mason-lspconfig.nvim", opts = {} },
  { "hrsh7th/cmp-nvim-lsp", cond = function() return Util.has("nvim-cmp") end },

  -- Formatters/linters
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = function()
      local builtins = require("null-ls").builtins
      local opts = Config.lsp
      ---@type any[]
      local sources = {}
      for k, v in pairs(Util.copy_as_table(opts.formatters)) do
        table.insert(sources, builtins.formatting[k]:with(v))
      end
      for k, v in pairs(Util.copy_as_table(opts.linters)) do
        table.insert(sources, builtins.diagnostics[k]:with(v))
      end
      return { sources = sources }
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
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
      },
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
