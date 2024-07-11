local M = {}

local git, semver = require "lazy.manage.git", require "lazy.manage.semver"

local function get_version(plugin)
  local ver = semver.last(git.get_versions(plugin.dir))
  if ver then return ("^%d.%d"):format(ver.major, ver.minor) end
end

local function get_commit(plugin)
  local branch = assert(git.get_branch(plugin))
  return git.get_commit(plugin.dir, branch)
end

local function get_snapshot(plugin)
  local version, commit = get_version(plugin)
  if not version then commit = get_commit(plugin) end
  return { plugin.name, version = version, commit = commit }
end

---Generate a snapshot to pin plugins.
---
---Credit: https://github.com/AstroNvim/AstroNvim/blob/62a0a7a/lua/astronvim/dev.lua
---@param current? LazyPluginSpec[] previous snapshot
---@return LazyPluginSpec[]
function M.generate_snapshot(current)
  local snapshots = {}
  if not current then -- generate snashot for all plugins
    local plugins = require("lazy").plugins()
    table.sort(plugins, function(a, b) return a.name < b.name end)

    for _, plugin in pairs(plugins) do
      table.insert(snapshots, get_snapshot(plugin))
    end
  else -- only generate for defined plugins
    ---@type table<string,LazyPlugin>
    local plugins = {}
    for _, plugin in ipairs(require("lazy").plugins()) do
      plugins[plugin.name] = plugin
    end

    for _, snap in ipairs(current) do
      local plugin = plugins[snap[1]] --[[@as LazyPluginSpec]]
      if not plugin then error(("spec for plugin %q not found"):format(snap[1])) end
      table.insert(snapshots, get_snapshot(plugin))
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
