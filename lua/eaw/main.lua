---@class eaw.main.GetOpts
---@field detail boolean

local Table = require("eaw.table")

---@class eaw.main.Eaw
---@field nvim eaw.nvim.Nvim
---@field table eaw.table.Table
local Eaw = {}

---@param nvim eaw.nvim.Nvim
---@return eaw.main.Eaw
Eaw.new = function(nvim)
	return setmetatable({ nvim = nvim, table = Table.new(nvim) }, { __index = Eaw })
end

---comment
---@param char string
---@param opts eaw.main.GetOpts?
---@return eaw.table.Entry|string
function Eaw:get(char, opts)
	---@type eaw.main.GetOpts
	opts = vim.tbl_extend("force", { detail = false }, opts or {})
	local entry = self.table:search(char)
	return opts.detail and entry or entry.sign
end

return Eaw
