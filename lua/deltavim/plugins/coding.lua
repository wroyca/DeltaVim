local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

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
    version = false, -- Last release is way too old
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      local mapping = cmp.mapping

      local function has_words_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api
              .nvim_buf_get_lines(0, line - 1, line, true)[1]
              :sub(col, col)
              :match("%s")
            == nil
      end

      local super_tab = mapping(function(fallback)
        local luasnip = require("luasnip")
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end)

      local super_stab = mapping(function(fallback)
        local luasnip = require("luasnip")
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end)

      -- Collect key mappings.
      local behavior = { behavior = cmp.SelectBehavior.Insert }
      local mappings = Keymap.Collector()
        :map({
          { "@cmp.super_tab", super_tab },
          { "@cmp.super_stab", super_stab },
          { "@cmp.next_item", mapping.select_next_item(behavior) },
          { "@cmp.prev_item", mapping.select_prev_item(behavior) },
          { "@cmp.scroll_up", mapping.scroll_docs(-4) },
          { "@cmp.scroll_down", mapping.scroll_docs(4) },
          { "@cmp.complete", mapping.complete({}) },
          { "@cmp.abort", mapping.abort() },
          { "@cmp.confirm", mapping.confirm({ select = true }) },
        })
        :collect_lhs_table()

      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        mapping = mappings,
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        formatting = {
          format = function(_, item)
            local icons = Config.icons.kind
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
    config = function(_, opts)
      local cmp = require("cmp")
      local sources = cmp.config.sources(opts.sources or {})
      cmp.setup(Util.merge({}, opts, { sources = sources }))
    end,
  },

  -- Auto pairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    config = function(_, opts) require("mini.pairs").setup(opts) end,
  },

  -- Surround
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      return Keymap.Collector()
        :map_unique({
          { "@surround.add", mode = { "n", "x" } },
          { "@surround.delete", mode = "n" },
          { "@surround.find", mode = "n" },
          { "@surround.find_left", mode = "n" },
          { "@surround.highlight", mode = "n" },
          { "@surround.replace", mode = "n" },
          { "@surround.update_n_lines", mode = "n" },
        })
        :collect_lazy(keys)
    end,
    opts = function()
      local mappings = Keymap.Collector()
        :map_unique({
          { "@surround.add", "add" },
          { "@surround.delete", "delete" },
          { "@surround.find", "find" },
          { "@surround.find_left", "find_left" },
          { "@surround.highlight", "highlight" },
          { "@surround.replace", "replace" },
          { "@surround.update_n_lines", "update_n_lines" },
        })
        :collect_rhs_table()
      return { mappings = mappings }
    end,
    config = function(_, opts) require("mini.surround").setup(opts) end,
  },

  -- Comments
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = function()
      local mappings = Keymap.Collector()
        :map_unique({
          { "@comment.toggle", "comment" },
          { "@comment.toggle", "text_object" },
          { "@comment.toggle_line", "comment_line" },
        })
        :collect_rhs_table()
      return {
        mappings = mappings,
        hooks = {
          pre = function()
            require("ts_context_commentstring.internal").update_commentstring({})
          end,
        },
      }
    end,
    config = function(_, opts) require("mini.comment").setup(opts) end,
  },
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },

  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }),
          c = ai.gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner",
          }),
        },
      }
    end,
    config = function(_, opts) require("mini.ai").setup(opts) end,
  },
}
