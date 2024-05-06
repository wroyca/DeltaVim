return {
  neotree_start = {
    {
      event = "BufEnter",
      desc = "Open Explorer on startup with directory",
      callback = function()
        if package.loaded["neo-tree"] or not require("astrocore").is_available "neo-tree.nvim" then
          return true
        end

        -- TODO: remove vim.loop after NeoVim v0.9
        local stats = (vim.uv or vim.loop).fs_stat(vim.api.nvim_buf_get_name(0))
        if stats and stats.type == "directory" then
          require("lazy").load { plugins = { "neo-tree.nvim" } }
          return true
        end
      end,
    },
  },
  neotree_refresh = {
    {
      event = "TermClose",
      desc = "Refresh Explorer sources when closing terminal",
      callback = function()
        local ok, manager = pcall(require, "neo-tree.sources.manager")
        if not ok then return true end
        if package.loaded["neo-tree.sources.filesystem"] then manager.refresh "filesystem" end
      end,
    },
  },
}
