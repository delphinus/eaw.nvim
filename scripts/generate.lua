local Nvim = require "eaw.nvim"
local Table = require "eaw.table"
local curl = require "plenary.curl"

local req = curl.get "http://www.unicode.org/Public/UCD/latest/ucd/EastAsianWidth.txt"
if not req or req.status ~= 200 then
  error "http get failed"
end
local result = {}
for line in req.body:gmatch "[^\r\n]+" do
  local pos_start, pos_end
  local codepoints, sign, general_category, others = line:match "^([%.%dA-F]+);([AFHNW]a?)%s+#%s(..)%s+(.*)$"
  if codepoints then
    if codepoints:match "%.%." then
      pos_start, pos_end = codepoints:match "(.*)%.%.(.*)"
      pos_start = tonumber(pos_start, 16)
      pos_end = tonumber(pos_end, 16)
    else
      pos_start = tonumber(codepoints, 16)
      pos_end = pos_start
    end
    local count, comment
    if others:match "^%[" then
      count, comment = others:match "^%[(%d+)%]%s(.*)$"
      count = tonumber(count)
    else
      count = 1
      comment = others
    end
    if codepoints then
      table.insert(result, {
        pos_start,
        pos_end,
        sign,
        general_category,
        count,
        comment,
      })
    end
  end
end

local tbl = Table.new(Nvim.new(), result)
tbl:save()
