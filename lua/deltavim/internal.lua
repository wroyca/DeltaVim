local M = {}

local function git_commit(dir)
  return vim.trim(assert(vim.fn.system { "git", "-C", dir, "rev-parse", "HEAD" }))
end

---Generate a snapshot to pin plugins.
---@param current? LazyPluginSpec[] previous snapshot
---@return LazyPluginSpec[]
-- credit: https://github.com/AstroNvim/AstroNvim/blob/62a0a7a/lua/astronvim/dev.lua
function M.generate_snapshot(current)
  local snapshots = {}
  if not current then
    local plugins = require("lazy").plugins()
    table.sort(plugins, function(a, b) return a.name < b.name end)

    for _, plugin in pairs(plugins) do
      table.insert(snapshots, { plugin.name, commit = git_commit(plugin.dir) })
    end
  else
    ---@type table<string,LazyPlugin>
    local plugins = {}
    for _, plugin in ipairs(require("lazy").plugins()) do
      plugins[plugin.name] = plugin
    end

    for _, snap in ipairs(current) do
      local plugin = plugins[snap[1]] --[[@as LazyPluginSpec]]
      if not plugin then error(("spec for plugin %q not found"):format(snap[1])) end

      local new_snap = { snap[1] }
      if snap.version then -- preserve manually pinned versions
        new_snap.version = snap.version
      else -- pin by commit
        new_snap.commit = git_commit(plugin.dir)
      end

      table.insert(snapshots, new_snap)
    end
  end

  return snapshots
end

---Updates the current snapshot.
---@param path? string path to the current snapshot
function M.update_snapshot(path)
  path = path
    or require("deltavim.utils").get_plugin("DeltaVim").dir .. "/lua/deltavim/snapshot.lua"
  local ok, current = pcall(dofile, path)
  local new_snapshot = M.generate_snapshot(ok and current or nil)

  local file, err = io.open(path, "w")
  if not file then error(("failed to open file: %s"):format(err)) end

  file:write "-- stylua: ignore\nreturn {\n"
  for _, snap in ipairs(new_snapshot) do
    file:write(("  { %q, optional = true"):format(snap[1]))

    if snap.commit then file:write((", commit = %q"):format(snap.commit)) end
    if snap.version then file:write((", version = %q"):format(snap.version)) end

    file:write " },\n"
  end
  file:write "}\n"
end

return M
