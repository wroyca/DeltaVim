return {
  resession_auto_save = {
    {
      event = "VimLeavePre",
      desc = "Save session on exit",
      callback = function()
        local ok, resession = pcall(require, "resession")
        if not ok then return end

        local astro_buf = require "astrocore.buffer"
        local autosave = astro_buf.sessions.autosave
        if autosave and astro_buf.is_valid_session() then
          if autosave.last then resession.save("last", { notify = false }) end
          if autosave.cwd then
            resession.save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
          end
        end
      end,
    },
  },
}
