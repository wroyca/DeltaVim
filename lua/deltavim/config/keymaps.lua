-- TODO: add plugin keymaps

local Keymap = require("deltavim.core.keymap")
local Util = require("deltavim.util")

local M = {}

---@type DeltaVim.Keymap[]
M.DEFAULT = {}

---@type DeltaVim.Keymap[]
local CONFIG

function M.init() CONFIG = Util.load_table("config.keymaps") or M.DEFAULT end

function M.setup() Keymap.load(CONFIG):map({}):collect_and_set() end

return M
