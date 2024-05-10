local utils = require "deltavim.utils"

local opt = {
  backspace = utils.concat(vim.opt.backspace:get(), { "nostop" }), -- don't stop backspace at insert
  breakindent = true, -- wrap indent to match  line start
  clipboard = "unnamed", -- connection to the system clipboard
  cmdheight = 0, -- hide command line unless needed
  completeopt = { "menu", "menuone", "noselect" }, -- Options for insert mode completion
  conceallevel = 3, -- hide * markup for bold and italic
  confirm = true, -- raise a dialog asking if you wish to save the current file(s)
  copyindent = true, -- copy the previous indentation on autoindenting
  cursorline = true, -- highlight the text line of the cursor
  diffopt = utils.concat(vim.opt.diffopt:get(), { "algorithm:histogram", "linematch:60" }), -- enable linematch diff algorithm
  expandtab = true, -- enable the use of space in tab
  fillchars = {
    foldopen = "",
    foldclose = "",
    fold = " ",
    foldsep = " ",
    diff = "╱",
    eob = " ",
  },
  foldcolumn = "1", -- show foldcolumn
  foldenable = true, -- enable fold for nvim-ufo
  foldlevel = 99, -- set high foldlevel for nvim-ufo
  foldlevelstart = 99, -- start with all code unfolded
  formatoptions = "jcroqlnvt", -- tcqj
  grepformat = "%f:%l:%c:%m",
  ignorecase = true, -- case insensitive searching
  inccommand = "nosplit", -- preview incremental substitute
  infercase = true, -- infer cases in keyword completion
  laststatus = 3, -- global statusline
  linebreak = true, -- wrap lines at 'breakat'
  list = true, -- Show some invisible characters (tabs...
  mouse = "a", -- enable mouse support
  number = true, -- show numberline
  preserveindent = true, -- preserve indent structure as much as possible
  pumblend = 10, -- Popup blend
  pumheight = 10, -- height of the pop up menu
  relativenumber = true, -- show relative numberline
  scrolloff = 4, -- Lines of context
  shiftround = true, -- Round indent
  shiftwidth = 0, -- number of space inserted for indentation
  shortmess = utils.merge(vim.opt.shortmess:get(), { s = true, I = true }), -- disable search count wrap and startup messages
  showmode = false, -- disable showing modes in command line
  showtabline = 2, -- always display tabline
  sidescrolloff = 8, -- Columns of context
  signcolumn = "yes", -- always show the sign column
  smartcase = true, -- case sensitive searching
  smartindent = true, -- Insert indents automatically
  spelllang = { "en" },
  splitbelow = true, -- splitting a new window below the current one
  splitkeep = "screen",
  splitright = true, -- splitting a new window at the right of the current one
  tabstop = 2, -- number of space in a tab
  termguicolors = true, -- enable 24-bit RGB color in the TUI
  timeoutlen = 500, -- shorten key timeout length a little bit for which-key
  title = true, -- set terminal title to the filename and path
  undofile = true, -- enable persistent undo
  undolevels = 10000,
  updatetime = 300, -- length of time to wait before triggering the plugin
  viewoptions = vim.tbl_filter(function(val) return val ~= "curdir" end, vim.opt.viewoptions:get()),
  virtualedit = "block", -- allow going past end of line in visual block mode
  wildmode = "longest:full,full", -- command-line completion mode
  winminwidth = 5, -- Minimum window width
  wrap = false, -- disable wrapping of lines longer than the width of window
  writebackup = false, -- disable making a backup before overwriting a file
}

if vim.fn.executable "rg" == 1 then opt.grepprg = "rg ,--vimgrep" end
---@diagnostic disable-next-line: inject-field
if not vim.t.bufs then vim.t.bufs = vim.api.nvim_list_bufs() end

return {
  opt = opt,
  g = {
    markdown_recommended_style = 0, -- fix markdown indentation settings
  },
  t = {
    bufs = vim.t.bufs,
  },
}
