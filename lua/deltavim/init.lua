local M = {}

---@param opts? table
function M.setup(opts)
  if opts == nil or vim.tbl_count(opts) == 0 then
    require("deltavim.core.config").setup()
  else
    require("deltavim.core.log").warn(
      "You should use 'config.options' to override default configurations"
    )
  end
end

return M
