return {
  buf_filter = function(bufnr) return require("astrocore.buffer").is_restorable(bufnr) end,
  tab_buf_filter = function(tabpage, bufnr) return vim.tbl_contains(vim.t[tabpage].bufs, bufnr) end,
  extensions = { astrocore = { enable_in_tab = true } },
}
