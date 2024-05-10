return function(_, opts)
  local ts = require "nvim-treesitter.configs"

  -- disable all treesitter modules on large buffer
  if require("astrocore").config.features.large_buf then
    for _, module in ipairs(ts.available_modules()) do
      local module_opts = opts[module] or {}
      local disable = module_opts.disable
      module_opts.disable = function(lang, bufnr)
        return vim.b[bufnr].large_buf
          or (type(disable) == "table" and vim.tbl_contains(disable, lang))
          or (type(disable) == "function" and disable(lang, bufnr))
      end
      opts[module] = module_opts
    end
  end

  ts.setup(opts)
end
