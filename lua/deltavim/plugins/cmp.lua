---@type LazyPluginSpec
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",

  dependencies = {
    { "hrsh7th/cmp-buffer", lazy = true },
    { "hrsh7th/cmp-path", lazy = true },
    { "cmp-nvim-lsp", optional = true },
  },

  opts = function()
    local cmp, astro = require "cmp", require "astrocore"

    local mapping = {
      ["<C-Y>"] = cmp.config.disable,

      ["<Up>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Select },
      ["<Down>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Select },
      ["<C-P>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
      ["<C-N>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },

      ["<C-U>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
      ["<C-D>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),

      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
      ["<CR>"] = cmp.mapping.confirm { select = false },
      ["<C-E>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },

      ["<Tab>"] = cmp.mapping(function(fallback)
        if vim.snippet and vim.snippet.active { direction = 1 } then
          vim.schedule(function() vim.snippet.jump(1) end)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if vim.snippet and vim.snippet.active { direction = -1 } then
          vim.schedule(function() vim.snippet.jump(-1) end)
        else
          fallback()
        end
      end, { "i", "s" }),
    }

    local icon = require("astroui").get_icon
    ---@type cmp.ConfigSchema
    return {
      enabled = function()
        if vim.bo[0].buftype == "prompt" then return false end
        ---@diagnostic disable-next-line: undefined-field
        return vim.b.cmp_enabled ~= false or astro.config.features.cmp ~= false
      end,
      snippet = {
        expand = function(args)
          if vim.snippet then vim.snippet.expand(args.body) end
        end,
      },
      formatting = {
        expandable_indicator = true,
        fields = { "kind", "abbr" },
        format = function(_, item)
          item.kind = " " .. icon(item.kind) .. " "
          return item
        end,
      },
      confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      },
      completion = {
        completeopt = "menu,menuone",
      },
      window = {
        completion = {
          col_offset = -2,
          side_padding = 0,
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
      },
      sources = {
        { name = "buffer", priority = 500, group_index = 2 },
        { name = "nvim_lsp", priority = 1000 },
        { name = "path", priority = 250 },
      },
      mapping = mapping,
    }
  end,

  config = function(_, opts)
    for _, source in ipairs(opts.sources or {}) do
      if not source.group_index then source.group_index = 1 end
    end
    require("cmp").setup(opts)
  end,
}
