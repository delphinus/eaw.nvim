---@alias Entry { [1]: integer, [2]: integer, [3]: string, [4]: string, [5]: integer, [6]: string }

---@class eaw.table.Generated
---@field version string
---@field entries Entry[]

---@class eaw.table.Entry
---@field pos_start integer
---@field pos_end integer
---@field sign string
---@field generator_factory string General_Category of the code point(s)
---@field count integer
---@field comment string

---@class eaw.table.Table
---@field nvim eaw.nvim.Nvim
---@field version string
---@field table Entry[]
local Table = {}

---@param nvim eaw.nvim.Nvim
---@param generated eaw.table.Generated?
---@return eaw.table.Table
Table.new = function(nvim, generated)
  generated = generated or require "eaw.generated"
  if type(generated) ~= "table" or type(generated.entries) ~= "table" then
    error "eaw.generated is broken. Run scripts/generate.lua to regenerate it."
  end
  return setmetatable({ nvim = nvim, version = generated.version, table = generated.entries }, { __index = Table })
end

---@param entry Entry
---@return eaw.table.Entry
local function to_detail(entry)
  return {
    pos_start = entry[1],
    pos_end = entry[2],
    sign = entry[3],
    generator_factory = entry[4],
    count = entry[5],
    comment = entry[6],
  }
end

---@param char string
---@return eaw.table.Entry
function Table:search(char)
  local code = vim.fn.char2nr(char)
  local entry = self:binary(code)
  if entry then
    return to_detail(entry)
  end
  -- Code points not listed in EastAsianWidth.txt are unassigned and default
  -- to "N" (see "@missing" in the file).
  return to_detail { code, code, "N", "Cn", 1, "<unassigned>" }
end

---@param code integer
---@return Entry?
function Table:binary(code)
  local lo, hi = 1, #self.table
  while lo <= hi do
    local mid = math.floor((lo + hi) / 2)
    local entry = self.table[mid]
    if code < entry[1] then
      hi = mid - 1
    elseif code > entry[2] then
      lo = mid + 1
    else
      return entry
    end
  end
end

return Table
