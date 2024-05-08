return {
  { cond = "heirline.nvim" },

  pick_select = {
    function()
      require("astroui.status.heirline").buffer_picker(
        function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end
      )
    end,
    desc = "Select buffer from tabline",
  },
  pick_close = {
    function()
      require("astroui.status.heirline").buffer_picker(
        function(bufnr) require("astrocore.buffer").close(bufnr) end
      )
    end,
    desc = "Close buffer from tabline",
  },
  pick_hsplit = {
    function()
      require("astroui.status.heirline").buffer_picker(function(bufnr)
        vim.cmd.split()
        vim.api.nvim_win_set_buf(0, bufnr)
      end)
    end,
    desc = "Horizontal split buffer from tabline",
  },
  pick_vsplit = {
    function()
      require("astroui.status.heirline").buffer_picker(function(bufnr)
        vim.cmd.vsplit()
        vim.api.nvim_win_set_buf(0, bufnr)
      end)
    end,
    desc = "Vertical split buffer from tabline",
  },
}
