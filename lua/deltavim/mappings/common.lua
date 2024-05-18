return {
  j = { "v:count == 0 ? 'gj' : 'j'", expr = true, silent = true, desc = "Move cursor down" },
  k = { "v:count == 0 ? 'gk' : 'k'", expr = true, silent = true, desc = "Move cursor up" },

  search_current_word = {
    function()
      vim.fn.setreg("/", "\\<" .. vim.fn.expand "<cword>" .. "\\>")
      vim.o.hlsearch = true
    end,
    desc = "Search current word",
  },

  new_file = { "<Cmd>enew<CR>", desc = "New file" },
  save_file = { "<Cmd>silent! w<CR>", desc = "Save file" },

  left_window = { "<Cmd>wincmd h<CR>", desc = "Goto left window" },
  down_window = { "<Cmd>wincmd j<CR>", desc = "Goto down window" },
  up_window = { "<Cmd>wincmd k<CR>", desc = "Goto up window" },
  right_window = { "<Cmd>wincmd l<CR>", desc = "Goto right window" },

  resize_left = { "<Cmd>vertical resize -3<CR>", desc = "Resize window up" },
  resize_down = { "<Cmd>resize +3<CR>", desc = "Resize window down" },
  resize_up = { "<Cmd>resize -3<CR>", desc = "Resize window left" },
  resize_right = { "<Cmd>vertical resize +3<CR>", desc = "Resize window right" },

  vsplit = { "<Cmd>vsplit<CR>", desc = "Vertical split" },
  hsplit = { "<Cmd>split<CR>", desc = "Horizontal split" },

  open_quickfix = { "<Cmd>copen<CR>", desc = "Open quickfix panel" },
  clear_quickfix = { function() vim.fn.setqflist {} end, desc = "Clear quickfix items" },

  next_quickfix = { "<Cmd>cnext<CR>", desc = "Next quickfix item" },
  prev_quickfix = { "<Cmd>cprevious<CR>", desc = "Previous quickfix item" },

  close_window = { "<Cmd>wincmd q<CR>", desc = "Close current window" },
  quit = { "<Cmd>confirm qall<CR>", desc = "Quit Neovim" },

  system_open = {
    -- TODO: remove astrocore.system_open in Neovim v0.10
    vim.ui.open or function(...) require("astrocore").system_open(...) end,
    desc = "Open the file under cursor with system app",
  },
}
