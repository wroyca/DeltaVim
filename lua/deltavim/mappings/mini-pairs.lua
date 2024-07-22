return {
  { cond = "mini.pairs" },

  toggle_buffer = {
    function() vim.b.minipairs_disable = vim.b.minipairs_disable == false end,
    desc = "Toggle autopairs (buffer)",
  },
  toggle_global = {
    function() vim.g.minipairs_disable = vim.g.minipairs_disable == false end,
    desc = "Toggle autopairs (global)",
  },
}
