local plugin = require("lazy.core.config").spec.plugins["mini.comment"]
local opts = require("lazy.core.plugin").values(plugin, "opts", false)

local mappings = opts.mappings
if not mappings then return {} end

return {
  { mappings.comment or "gc", desc = "Comment toggle" },
  { mappings.comment_visual or "gc", mode = "x", desc = "Comment toggle (visual)" },
  { mappings.comment_line or "gcc", desc = "Comment toggle current line" },
  { mappings.textobject or "gc", mode = "o", desc = "Comment lines" },
}
