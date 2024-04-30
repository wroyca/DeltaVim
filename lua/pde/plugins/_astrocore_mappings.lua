return {
  "AstroNvim/astrocore",
  ---@param opts AstroCoreOpts
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon
    -- initialize internally use mapping section titles
    opts._map_sections = {
      f = { desc = get_icon("Search", 1, true) .. "Find" },
      l = { desc = get_icon("ActiveLSP", 1, true) .. "Language Tools" },
      d = { desc = get_icon("Debugger", 1, true) .. "Debugger" },
      g = { desc = get_icon("Git", 1, true) .. "Git" },
      t = { desc = get_icon("Terminal", 1, true) .. "Terminal" },
    }

    -- initialize mappings table
    local maps = require("astrocore").empty_map_table()
    local sections = assert(opts._map_sections)

    maps.n["<Leader>l"] = vim.tbl_get(sections, "l")
    maps.n["<Leader>ld"] =
      { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }
    maps.n["[d"] = { function() vim.diagnostic.goto_prev() end, desc = "Previous diagnostic" }
    maps.n["]d"] = { function() vim.diagnostic.goto_next() end, desc = "Next diagnostic" }
    maps.n["gl"] = { function() vim.diagnostic.open_float() end, desc = "Hover diagnostics" }

    opts.mappings = maps
  end,
}
