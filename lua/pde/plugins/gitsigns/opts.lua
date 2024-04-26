local icon = require("astroui").get_icon

return {
  signs = {
    add = { text = icon "GitSign" },
    change = { text = icon "GitSign" },
    delete = { text = icon "GitSign" },
    topdelete = { text = icon "GitSign" },
    changedelete = { text = icon "GitSign" },
    untracked = { text = icon "GitSign" },
  },
  worktrees = require("astrocore").config.git_worktrees,
}
