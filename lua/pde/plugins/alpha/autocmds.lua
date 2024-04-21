return {
  alpha_autostart = {
    {
      event = "VimEnter",
      desc = "Start Alpha when vim is opened without arguments",
      once = true,
      callback = function()
        if vim.fn.argc() > 0 then return end
        require("lazy").load { plugins = { "alpha-nvim" } }
        require("alpha").start(true)
        vim.schedule(function() vim.cmd.doautocmd "FileType" end)
      end,
    },
  },
  alpha_settings = {
    {
      event = { "User", "BufWinEnter" },
      desc = "Disable status, tablines, and cmdheight for Alpha",
      callback = function(ev)
        local before = vim.g.before_alpha
        local keys = { "showtabline", "laststatus", "cmdheight" }

        if
          not before
          and (
            (ev.event == "User" and ev.file == "AlphaReady")
            or (ev.event == "BufWinEnter" and vim.bo[ev.buf].filetype == "alpha")
          )
        then
          before = {}
          for _, k in ipairs(keys) do
            before[k] = vim.opt[k]:get()
            vim.opt[k] = 0
          end
          vim.g.before_alpha = before
        elseif before and ev.event == "BufWinEnter" and vim.bo[ev.buf].buftype ~= "nofile" then
          for _, k in ipairs(keys) do
            vim.opt[k] = before[k]
          end
          vim.g.before_alpha = nil
        end
      end,
    },
  },
}
