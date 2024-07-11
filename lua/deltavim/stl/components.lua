local M = {}

local astro = require "astrocore"
local status, config = require "astroui.status", assert(require("astroui").config.status)
local hl, component, extend_tbl = status.hl, status.component, astro.extend_tbl

---A function to build a component for automatic sidebar padding with a title.
---@param opts? table options for configuring builder settings
---@return table # The Heirline component table
function M.sidebar_title(opts)
  opts = extend_tbl({
    provider = function()
      ---@cast config +{sidebar_titles?:table<string,string>}
      local sidebar_titles = config.sidebar_titles or {}

      ---traverse windows from left to right,
      local all_titles = ""
      for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- if a window is configured as a sidebar,
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local title = sidebar_titles[vim.bo[bufnr].filetype]
        if not title then break end
        -- add left offset with the given title to the tabline
        local padding = vim.api.nvim_win_get_width(winid) - #title
        local left = math.floor(padding / 2)
        all_titles = all_titles .. (" "):rep(left) .. title .. (" "):rep(padding - left)
      end

      return all_titles == "" and nil or all_titles
    end,
    update = { "WinResized" },
    hl = hl.get_attributes("sidebar_title", true),
  }, opts)
  return component.builder(opts)
end

return M
