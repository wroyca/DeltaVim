local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

return {
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows")) and "make install_jsregexp" or nil,
    dependencies = { "friendly-snippets" },
    keys = function()
      ---@param dir integer
      ---@return DeltaVim.Keymap.With
      local function jump_or_fallback(dir)
        return function(src)
          local key = src[1] --[[@as string]]
          return function()
            local luasnip = require("luasnip")
            if luasnip.locally_jumpable(dir) then
              luasnip.jump(dir)
            else
              Util.feedkey(key)
            end
          end
        end
      end

      local function jump(dir)
        return function() require("luasnip").jump(dir) end
      end

      return Keymap.Collector()
        :map({
          { "@snippet.next_node", with = jump_or_fallback(1), mode = "i" },
          { "@snippet.next_node", jump(1), mode = "s" },
          { "@snippet.prev_node", with = jump_or_fallback(-1), mode = "i" },
          { "@snippet.prev_node", jump(-1), mode = "s" },
        })
        :collect_lazy()
    end,
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
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
      local bordered = cmp.config.window.bordered

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
        elseif luasnip.locally_jumpable(-1) then
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
          { "@cmp.abort", mapping.abort() },
          { "@cmp.complete", mapping.complete({}) },
          { "@cmp.confirm", mapping.confirm({ select = true }) },
          { "@cmp.prev_item", mapping.select_prev_item(behavior) },
          { "@cmp.next_item", mapping.select_next_item(behavior) },
          { "@cmp.scroll_up", mapping.scroll_docs(-4) },
          { "@cmp.scroll_down", mapping.scroll_docs(4) },
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
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
        formatting = {
          format = function(_, item)
            local icons = Config.icons.kinds
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
        window = {
          completion = bordered(Config.border),
          documentation = bordered(Config.border),
        },
      }
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
    keys = function()
      -- stylua: ignore
      return Keymap.Collector()
        :map({
          { "@surround.add", desc = "Add surrounding", mode = { "n", "x" } },
          { "@surround.delete", desc = "Delete surrounding", mode = "n" },
          { "@surround.find", desc = "Next surrounding", mode = "n" },
          { "@surround.find_left", desc = "Prev surrounding", mode = "n" },
          { "@surround.highlight", desc = "Highlight surrounding", mode = "n" },
          { "@surround.replace", desc = "Replace surrounding", mode = "n" },
          { "@surround.update_n_lines", desc = "Update N lines surrounding", mode = "n" },
        })
        :collect_lazy()
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
      return {
        mappings = mappings,
        search_method = "cover",
      }
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
        search_method = "cover",
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- Register textobjects
      if Util.has("which-key.nvim") then
        ---@type table<string, string>
        local a = {
          ["("] = "Balanced (",
          [")"] = "Balanced )",
          ["<lt>"] = "Balanced <",
          [">"] = "Balanced >",
          ["["] = "Balanced [",
          ["]"] = "Balanced ]",
          ["{"] = "Balanced {",
          ["}"] = "Balanced }",
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["?"] = "User Prompt",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced ) ] }",
          c = "Class",
          f = "Function",
          o = "Block/conditional/loop",
          q = "Quote ` \" '",
          t = "Tag",
        }
        ---@type table<string, string>
        local i = {
          [")"] = "Balanced ) including whitespace",
          [">"] = "Balanced > including whitespace",
          ["]"] = "Balanced ] including whitespace",
          ["}"] = "Balanced } including whitespace",
        }
        ---@type table<string, string>
        local ai = {
          n = "Next textobject",
          l = "Last textobject",
        }
        for k, v in pairs(a) do
          i[k] = i[k] or v
        end
        for k, v in pairs(ai) do
          i[k] = v
          a[k] = v
        end
        require("which-key").register({
          mode = { "o", "x" },
          a = a,
          i = i,
        })
      end
    end,
  },
}
