return {
  { cond = "resession.nvim" },

  save = {
    function() require("resession").save() end,
    desc = "Save this session",
  },
  save_dir = {
    function() require("resession").save(vim.fn.getcwd(), { dir = "dirsession" }) end,
    desc = "Save this dirsession",
  },
  save_tab = {
    function() require("resession").save_tab() end,
    desc = "Save this tab's session",
  },

  load = {
    function() require("resession").load(nil, { silence_errors = true }) end,
    desc = "Load a session",
  },
  load_last = {
    function() require("resession").load("last", { silence_errors = true }) end,
    desc = "Load last session",
  },
  load_dir = {
    function() require("resession").load(nil, { dir = "dirsession", silence_errors = true }) end,
    desc = "Load a dirsession",
  },
  load_dir_cwd = {
    function()
      require("resession").load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true })
    end,
    desc = "Load current dirsession",
  },

  delete = {
    function() require("resession").delete() end,
    desc = "Delete a session",
  },
  delete_dir = {
    function() require("resession").delete(nil, { dir = "dirsession", silence_errors = true }) end,
    desc = "Delete a dirsession",
  },
}
