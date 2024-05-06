return {
  next = {
    function() require("todo-comments").jump_next() end,
    desc = "Next TODO comment",
  },
  prev = {
    function() require("todo-comments").jump_prev() end,
    desc = "Previous TODO comment",
  },

  find = {
    function()
      require("telescope").extensions["todo-comments"].todo {
        keywords = "TODO,FIX,FIXME",
      }
    end,
    desc = "Find TODO/FIXMEs",
  },
  find_all_kinds = {
    function() require("telescope").extensions["todo-comments"].todo() end,
    desc = "Find TODO comments",
  },
}
