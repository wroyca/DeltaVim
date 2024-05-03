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
  preview_config = { border = require("pde").get_border "popup_border" },
  worktrees = require("astrocore").config.git_worktrees,
}
