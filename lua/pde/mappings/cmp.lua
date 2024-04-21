return {
  toggle_buffer = {
    function() require("astrocore.toggles").buffer_cmp() end,
    desc = "Toggle autocompletion (buffer)",
  },
  toggle_global = {
    function() require("astrocore.toggles").cmp() end,
    desc = "Toggle autocompletion (global)",
  },
}
