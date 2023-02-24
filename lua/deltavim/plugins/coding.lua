local Keymap = require("deltavim.core.keymap")

return {
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "friendly-snippets" },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    keys = function()
      ---@param dir integer
      local function jump_or_fallback(dir)
        ---@param src DeltaVim.Keymap.Input
        ---@return DeltaVim.Keymap ...
        return function(src)
          local key = src[1]
          return {
            key,
            function()
              local luasnip = require("luasnip")
              if luasnip.locally_jumpable(dir) then
                luasnip.jump(dir)
              else
                return key
              end
            end,
            mode = "i",
            expr = true,
          }
        end
      end

      return Keymap.Collector()
        :map({
          {
            "@snippet.next_node",
            with = jump_or_fallback(1),
            mode = "i",
          },
          {
            "@snippet.next_node",
            function() require("luasnip").jump(1) end,
            mode = "s",
          },
          {
            "@snippet.prev_node",
            with = jump_or_fallback(-1),
            mode = "i",
          },
          {
            "@snippet.prev_node",
            function() require("luasnip").jump(-1) end,
            mode = "s",
          },
        })
        :collect_lazy()
    end,
  },
  {
    "rafamadriz/friendly-snippets",
    config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
  },

  -- Auto completion
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")

      -- Collect key mappings.
      local factory = cmp.mapping
      local behavior = { behavior = cmp.SelectBehavior.Insert }
      local mapping = Keymap.Collector()
        :map({
          { "@cmp.next_item", factory.select_next_item(behavior) },
          { "@cmp.prev_item", factory.select_prev_item(behavior) },
          { "@cmp.scroll_up", factory.scroll_docs(-4) },
          { "@cmp.scroll_down", factory.scroll_docs(4) },
          { "@cmp.complete", factory.complete() },
          { "@cmp.abort", factory.abort() },
          { "@cmp.confirm", factory.confirm({ select = true }) },
        })
        :collect_lhs_table()

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = mapping,
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(_, item)
            local icons = require("lazyvim.config").icons.kinds
            if icons[item.kind] then
              item.kind = icons[item.kind] .. item.kind
            end
            return item
          end,
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      }
    end,
  },
}
