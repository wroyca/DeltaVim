return {
  install = {
    function() require("lazy").install() end,
    desc = "Install packages",
  },
  show_status = {
    function() require("lazy").home() end,
    desc = "Show packages status",
  },
  sync = {
    function() require("lazy").sync() end,
    desc = "Sync packages",
  },
  check = {
    function() require("lazy").check() end,
    desc = "Check packages updates",
  },
  update = {
    function() require("lazy").update() end,
    desc = "Update packages",
  },
}
