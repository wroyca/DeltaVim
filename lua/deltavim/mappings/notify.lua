return {
  { cond = "nvim-notify" },

  find = {
    function() require("telescope").extensions.notify.notify() end,
    desc = "Find notifications",
  },
  dismiss = {
    function() require("notify").dismiss { pending = true, silent = true } end,
    desc = "Dismiss notifications",
  },
}
