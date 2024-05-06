return function(_, opts)
  local ufo = require "ufo"
  ufo.setup(opts)
  local map = vim.keymap.set
  map("n", "zm", ufo.closeFoldsWith)
  map("n", "zM", ufo.closeAllFolds)
  map("n", "zr", ufo.openFoldsExceptKinds)
  map("n", "zR", ufo.openAllFolds)
  map("n", "zp", ufo.peekFoldedLinesUnderCursor)
end
