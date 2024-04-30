local cms_ok, cms = pcall(require, "ts_context_commentstring")

return {
  options = {
    custom_commentstring = function()
      return cms_ok and cms.calculate_commentstring() or vim.bo.commentstring
    end,
    mappings = {
      comment = "gc",
      comment_line = "gcc",
      comment_visual = "gc",
      textobject = "gc",
    },
  },
}
