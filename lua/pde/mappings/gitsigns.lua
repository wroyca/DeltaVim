return {
  next_hunk = {
    function() require("gitsigns").next_hunk() end,
    desc = "Goto next hunk",
  },
  prev_hunk = {
    function() require("gitsigns").prev_hunk() end,
    desc = "Goto previous hunk",
  },

  reset_hunk = {
    function() require("gitsigns").reset_hunk() end,
    desc = "Reset current hunk",
  },
  reset_buffer = {
    function() require("gitsigns").reset_buffer() end,
    desc = "Reset buffer changes",
  },
  stage_hunk = {
    function() require("gitsigns").stage_hunk() end,
    desc = "Stage current hunk",
  },
  stage_buffer = {
    function() require("gitsigns").stage_buffer() end,
    desc = "Stage buffer changes",
  },
  undo_stage_hunk = {
    function() require("gitsigns").undo_stage_hunk() end,
    desc = "Undo stage hunk",
  },

  show_blame = {
    function() require("gitsigns").blame_line() end,
    desc = "Show current blame",
  },
  show_full_blame = {
    function() require("gitsigns").blame_line { full = true } end,
    desc = "Show current full blame",
  },
  show_hunk = {
    function() require("gitsigns").preview_hunk_inline() end,
    desc = "Show current hunk",
  },
  show_diff = {
    function() require("gitsigns").diffthis() end,
    desc = "Show Git diff",
  },
}
