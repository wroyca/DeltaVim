return {
  { cond = "nvim-cmp" },

  toggle_buffer = {
    function() require("astrocore.toggles").buffer_cmp() end,
    desc = "Toggle completion (buffer)",
  },
  toggle_global = {
    function() require("astrocore.toggles").cmp() end,
    desc = "Toggle completion (global)",
  },
}
