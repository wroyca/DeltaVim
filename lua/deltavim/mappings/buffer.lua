return {
  next = {
    function() require("astrocore.buffer").nav(vim.v.count1) end,
    desc = "Next buffer",
  },
  prev = {
    function() require("astrocore.buffer").nav(-vim.v.count1) end,
    desc = "Previous buffer",
  },

  move_left = {
    function() require("astrocore.buffer").move(-vim.v.count1) end,
    desc = "Move buffer to left",
  },
  move_right = {
    function() require("astrocore.buffer").move(vim.v.count1) end,
    desc = "Move buffer to right",
  },

  close = {
    function() require("astrocore.buffer").close() end,
    desc = "Close current buffer",
  },
  close_force = {
    function() require("astrocore.buffer").close(0, true) end,
    desc = "Force close current buffer",
  },
  close_left = {
    function() require("astrocore.buffer").close_left() end,
    desc = "Close all left buffers",
  },
  close_right = {
    function() require("astrocore.buffer").close_right() end,
    desc = "Close all right buffers",
  },
  close_others = {
    function() require("astrocore.buffer").close_all(true) end,
    desc = "Close other buffers",
  },
  close_all = {
    function() require("astrocore.buffer").close_all() end,
    desc = "Close all buffers",
  },

  sort_by_extension = {
    function() require("astrocore.buffer").sort "extension" end,
    desc = "Sort buffers by extension",
  },
  sort_by_filename = {
    function() require("astrocore.buffer").sort "unique_path" end,
    desc = "Sort buffers by relative path",
  },
  sort_by_path = {
    function() require("astrocore.buffer").sort "full_path" end,
    desc = "Sort buffers by full path",
  },
  sort_by_number = {
    function() require("astrocore.buffer").sort "bufnr" end,
    desc = "Sort buffers by buffer number",
  },
  sort_by_modification = {
    function() require("astrocore.buffer").sort "modified" end,
    desc = "Sort buffers by modification",
  },
}
