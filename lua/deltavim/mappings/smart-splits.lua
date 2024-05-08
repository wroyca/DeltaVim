return {
  { cond = "smart-splits.nvim" },

  left_window = {
    function() require("smart-splits").move_cursor_left() end,
    desc = "Goto left window",
  },
  down_window = {
    function() require("smart-splits").move_cursor_down() end,
    desc = "Goto down window",
  },
  up_window = {
    function() require("smart-splits").move_cursor_up() end,
    desc = "Goto right window",
  },
  right_window = {
    function() require("smart-splits").move_cursor_right() end,
    desc = "Goto right window",
  },

  resize_down = {
    function() require("smart-splits").resize_down() end,
    desc = "Resize window down",
  },
  resize_left = {
    function() require("smart-splits").resize_left() end,
    desc = "Resize window left",
  },
  resize_up = {
    function() require("smart-splits").resize_up() end,
    desc = "Resize window up",
  },
  resize_right = {
    function() require("smart-splits").resize_right() end,
    desc = "Resize window right",
  },
}
