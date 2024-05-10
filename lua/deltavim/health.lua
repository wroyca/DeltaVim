local M = {}

local health = vim.health

function M.check()
  health.start "DeltaVim"

  health.info("Neovim Version: v" .. vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\n]*"))

  if vim.version().prerelease then
    health.warn "Neovim nightly is not officially supported and may have breaking changes"
  elseif vim.fn.has "nvim-0.9" == 1 then
    health.ok "Using stable Neovim >= 0.9.0"
  else
    health.error "Neovim >= 0.9.0 is required"
  end

  local programs = {
    {
      cmd = { "git" },
      type = "error",
      msg = "Used for core functionality such as updater and plugin management",
    },
    {
      cmd = { "xdg-open", "rundll32", "explorer.exe", "open" },
      type = "warn",
      msg = "Used for `gx` mapping for opening files with system opener (Optional)",
    },
    {
      cmd = { "rg" },
      type = "warn",
      msg = "Used for `Telescope live_grep` (Optional)",
    },
  }

  for _, program in ipairs(programs) do
    local name = table.concat(program.cmd, "/")
    local found = false
    for _, cmd in ipairs(program.cmd) do
      if vim.fn.executable(cmd) == 1 then
        name = cmd
        if not program.extra_check or program.extra_check(program) then found = true end
        break
      end
    end

    if found then
      health.ok(("`%s` is installed: %s"):format(name, program.msg))
    else
      health[program.type](("`%s` is not installed: %s"):format(name, program.msg))
    end
  end
end

return M
