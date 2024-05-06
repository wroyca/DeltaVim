return {
  next_reference = {
    function() require("illuminate").goto_next_reference(true) end,
    desc = "Next reference",
  },
  prev_reference = {
    function() require("illuminate").goto_prev_reference(true) end,
    desc = "Previous reference",
  },

  toggle_buffer = {
    function() require("illuminate").toggle_buf() end,
    desc = "Toggle reference highlighting (buffer)",
  },
  toggle_global = {
    function() require("illuminate").toggle() end,
    desc = "Toggle reference highlighting (global)",
  },
}
