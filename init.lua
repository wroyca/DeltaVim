-- We can simply use `pcall(require, "pde")`, but that catches all errors and might lead to
-- confusion since we only want to catch the "module not found" error.
for _, searcher in ipairs(package.searchers) do
  local loader = type(searcher) == "function" and searcher "pde"
  if type(loader) == "function" then
    -- Entrypoint of user's configuration
    require "pde"
    break
  end
end
