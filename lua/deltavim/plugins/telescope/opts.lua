local actions = require "telescope.actions"
local icon = require("astroui").get_icon

return {
  defaults = {
    git_worktrees = require("astrocore").config.git_worktrees,
    prompt_prefix = icon("Selected", 1),
    selection_caret = icon("Selected", 1),
    path_display = { "truncate" },
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "bottom",
        preview_width = 0.55,
      },
      vertical = { mirror = false },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    mappings = {
      i = {
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
        ["<C-x>"] = actions.send_to_qflist + actions.open_qflist,
      },
      n = {
        q = actions.close,
      },
    },
  },
}
