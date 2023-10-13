local Config = require("deltavim.config")
local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

return {
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
        and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
      or nil,
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
        return function()
          require("luasnip").jump(dir)
        end
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
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
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
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

      local cmp = require("cmp")
      local mapping = cmp.mapping
      local defaults = require("cmp.config.default")()

      local super_tab = mapping(function(fallback)
        local luasnip = require("luasnip")
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.locally_jumpable(1) then
          luasnip.jump(1)
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

      local function confirm(behavior)
        return mapping.confirm({ behavior = behavior, select = true })
      end

      -- Collect key mappings.
      local insert = { behavior = cmp.SelectBehavior.Insert }
      local mappings = Keymap.Collector()
        :map({
          { "@cmp.super_tab", super_tab, key = "<Tab>" },
          { "@cmp.super_stab", super_stab, key = "<S-Tab>" },
          { "@cmp.abort", mapping.abort() },
          { "@cmp.complete", mapping.complete() },
          { "@cmp.confirm", confirm() },
          { "@cmp.confirm_replace", confirm(cmp.ConfirmBehavior.Replace) },
          { "@cmp.confirm_insert", confirm(cmp.ConfirmBehavior.Insert) },
          { "@cmp.prev_item", mapping.select_prev_item(insert) },
          { "@cmp.next_item", mapping.select_next_item(insert) },
          { "@cmp.scroll_up", mapping.scroll_docs(-4) },
          { "@cmp.scroll_down", mapping.scroll_docs(4) },
        })
        :collect_lhs_table()

      ---@class DeltaVim.Config.Cmp
      local opts = {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = mappings,
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        formatting = {
          source_names = {
            buffer = "[BUF]",
            calc = "[CALC]",
            cmp_tabnine = "[TABNINE]",
            copilot = "[COPILOT]",
            crates = "[CRATES]",
            emoji = "[EMOJI]",
            luasnip = "[SNIP]",
            nvim_lsp = "[LSP]",
            path = "[PATH]",
            tmux = "[TMUX]",
            treesitter = "[TS]",
            vsnip = "[SNIP]",
          },
          ---@param name string
          default_source_name = function(name)
            return string.format("[%s]", name:upper())
          end,
          source_dups = {
            buffer = 0,
            luasnip = 1,
            nvim_lsp = 1,
            path = 1,
          },
          default_source_dup = 1,
          max_width = function()
            return math.floor(vim.o.columns * 0.4)
          end,
        },
        sorting = defaults.sorting,
        experimental = {
          ghost_text = {
            hl_group = "CmpChostText",
          },
        },
      }
      return opts
    end,
    ---@param opts DeltaVim.Config.Cmp
    config = function(_, opts)
      vim.api.nvim_set_hl(0, "CmpChostText", { link = "Comment", default = true })
      local icons = Config.icons
      local formatting = opts.formatting
      require("cmp").setup(Util.deep_merge({
        formatting = {
          -- Credit: https://github.com/LunarVim/LunarVim/blob/1.2.0/lua/lvim/core/cmp.lua#L175-L212
          -- License: GPL-3.0
          format = function(entry, item)
            local source = entry.source.name
            local max_width = formatting.max_width()
            if #item.abbr > max_width then
              item.abbr = string.sub(item.abbr, 1, max_width) .. "..."
            end
            item.kind = icons[item.kind] and icons[item.kind] .. item.kind or item.kind
            item.menu = formatting.source_names[source] or formatting.default_source_name(source)
            item.dup = formatting.source_dups[source] or formatting.default_source_dup
            return item
          end,
        },
      }, opts))
    end,
  },

  -- Auto pairs
  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    opts = {
      mappings = {
        ["'"] = {
          action = "closeopen",
          pair = "''",
          neigh_pattern = "%s.",
          register = { cr = false },
        },
      },
    },
  },

  -- Surround
  {
    "echasnovski/mini.surround",
    keys = function()
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
      return { mappings = mappings }
    end,
  },

  -- Comments
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },
  {
    "echasnovski/mini.comment",
    event = "VeryLazy",
    keys = function()
      return Keymap.Collector()
        :map({
          { "@comment.toggle", desc = "Toggle comment", mode = { "n", "x" } },
          { "@comment.toggle_line", desc = "Toggle line comment", mode = "n" },
          { "@textobject.comment", desc = "Comment", mode = "o" },
        })
        :collect_lazy()
    end,
    opts = function()
      local mappings = Keymap.Collector()
        :map_unique({
          { "@comment.toggle", "comment" },
          { "@comment.toggle_line", "comment_line" },
          { "@select.comment", "textobject" },
        })
        :collect_rhs_table()
      return {
        options = {
          custom_commentstring = function()
            return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
          end,
        },
        mappings = mappings,
      }
    end,
  },

  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter-textobjects" },
    opts = function()
      local ai = require("mini.ai")
      return {
        custom_textobjects = {
          c = ai.gen_spec.treesitter({
            a = "@class.outer",
            i = "@class.inner",
          }),
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }),
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
        },
        n_lines = 500,
        search_method = "cover_or_next",
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
        require("which-key").register({ mode = { "o", "x" }, a = a, i = i })
      end
    end,
  },
}
