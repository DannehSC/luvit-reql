local intlib=require('./intlib.lua')
local cmanager=require('./coroutinemanager.lua')
local processor={}
local function newBuffer(tx)
	local buffer={data=tx}
	function buffer:add(tx)
		buffer.data=buffer.data..tx
	end
	return buffer
end
local int=intlib.byte_to_int
function processor.processData(data)
	local token=int(data:sub(1,8))
	local length=int(data:sub(9,12))
	local rest=data:sub(13)
	return token,length,rest
end
return processor