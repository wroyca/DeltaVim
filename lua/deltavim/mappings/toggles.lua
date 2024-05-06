return {
  toggle_autochdir = {
    function() require("astrocore.toggles").autochdir() end,
    desc = "Toggle rooter autochdir",
  },
  toggle_background = {
    function() require("astrocore.toggles").background() end,
    desc = "Toggle background",
  },
  toggle_conceal = {
    function() require("astrocore.toggles").conceal() end,
    desc = "Toggle conceal",
  },
  toggle_diagnostics = {
    function() require("astrocore.toggles").diagnostics() end,
    desc = "Toggle diagnostics",
  },
  toggle_foldcolumn = {
    function() require("astrocore.toggles").foldcolumn() end,
    desc = "Toggle foldcolumn",
  },
  toggle_indent = {
    function() require("astrocore.toggles").indent() end,
    desc = "Change indent setting",
  },
  toggle_notifications = {
    function() require("astrocore.toggles").notifications() end,
    desc = "Toggle Notifications",
  },
  toggle_number = {
    function() require("astrocore.toggles").number() end,
    desc = "Change line numbering",
  },
  toggle_paste = {
    function() require("astrocore.toggles").paste() end,
    desc = "Toggle paste mode",
  },
  toggle_signcolumn = {
    function() require("astrocore.toggles").signcolumn() end,
    desc = "Toggle signcolumn",
  },
  toggle_spell = {
    function() require("astrocore.toggles").spell() end,
    desc = "Toggle spellcheck",
  },
  toggle_statusline = {
    function() require("astrocore.toggles").statusline() end,
    desc = "Toggle statusline",
  },
  toggle_tabline = {
    function() require("astrocore.toggles").tabline() end,
    desc = "Toggle tabline",
  },
  toggle_url_match = {
    function() require("astrocore.toggles").url_match() end,
    desc = "Toggle URL highlight",
  },
  toggle_wrap = {
    function() require("astrocore.toggles").wrap() end,
    desc = "Toggle wrap",
  },
  toggle_syntax = {
    function() require("astrocore.toggles").buffer_syntax() end,
    desc = "Toggle syntax highlight",
  },
}
