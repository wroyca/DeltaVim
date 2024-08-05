-- A example module that shows how we manage mappings.
--
-- DeltaVim uses a centralized approach to mappings management, i.e. all
-- mappings are configured in a single file. You can find our default mappings
-- in `deltavim/presets/mappings.lua`.
--
-- To make it easier to reuse existing mappings, DeltaVim implements a simple
-- layer of mappings. As shown in the file mentioned above, you can use
-- something like `{ ["<key>"] = "<module>.<mapping>" }` to configure mappings,
-- where `<module>` is a file located at `deltavim/mappings/<module>.lua`, which
-- returns a table whose keys are the actual specs passed to `vim.keymap.set`.

return {
  {
    -- Configures whether to enable these mappings, it can be a boolean value, a
    -- function which returns a boolean, or a plugin name managed by lazy.nvim.
    -- When set to a plugin name, these mappings are only enabled if the plugin
    -- is enabled.
    cond = true,
    -- cond = function() return true end,
    -- cond = "deltavim",
  },

  hellp = {
    ":echo hello", -- function or command to bind
    desc = "Symbols outline", -- description
    noremap = true, -- and other valid keymap options
  },
}
