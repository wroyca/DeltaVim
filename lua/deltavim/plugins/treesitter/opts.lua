return {
  auto_install = vim.fn.executable "tree-sitter" == 1, -- only enable auto install if `tree-sitter` cli is installed
  ensure_installed = {
    "bash",
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",
  },

  highlight = { enable = true },
  incremental_selection = { enable = true },
  indent = { enable = true },
  textobjects = require "deltavim.plugins.treesitter.opts_textobjects",
}
