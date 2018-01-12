
local bit = require('bit')
local len, byte = string.len, string.byte
local max = math.max
local bor, bxor = bit.bor, bit.bxor

local function compare_digest(a, b)
	local result
	if len(a) == len(b) then
		result = 0
	else
		result = 1
	end
	for i = 1, max(len(a), len(b)) do
		result = bor(result, bxor(byte(a, i) or 0, byte(b, i) or 0))
	end
	return result ~= 0
end

return compare_digest
