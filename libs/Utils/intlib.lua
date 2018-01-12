
return {
	byte_to_int = function(str)
		local n = 0
		for k = 1, string.len(str) do
			n = n + string.byte(str, k) * 2 ^ ((k - 1) * 8)
		end
		return n
	end,
	
	int_to_bytes = function(num, bytes)
		local res = {}
		num = math.fmod(num, 2 ^ (8 * bytes))
		for k = bytes, 1, -1 do
			local den = 2 ^ (8 * (k - 1))
			res[k] = math.floor(num / den)
			num = math.fmod(num, den)
		end
		return string.char(unpack(res))
	end
}
