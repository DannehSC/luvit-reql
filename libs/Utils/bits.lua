local bit = require('bit')
local len, byte, char, max = string.len, string.byte, string.char, math.max
local bxor = bit.bxor

local function xor(t, U)
	for j = 1, len(U) do
		t[j] = bxor(t[j] or 0, byte(U, j) or 0)
	end
end

local function bxor256(u, t)
	local res = {}
	for i = 1, max(len(u), len(t)) do
		res[i] = bxor(byte(u, i) or 0, byte(t, i) or 0)
	end
	return char(unpack(res))
end

return {xor, bxor256}
