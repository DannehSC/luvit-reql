local intlib=require('./intlib.lua')
local protodef=require('./protodef.lua')
local cmanager=require('./coroutinemanager.lua')
local responses=protodef.Response
local callbacks={}
local processor={}
local buffers={}
local function newBuffer(tx)
	local buffer={data=tx}
	function buffer:add(tx)
		buffer.data=buffer.data..tx
	end
	return buffer
end
local int=intlib.byte_to_int
function processor.processData(data,callback)
	assert(type(callback)=='function','bad argument #1 to processor.processData, function expected.')
	local token=int(data:sub(1,8))
	local length=int(data:sub(9,12))
	local resp=data:sub(13)
	local t,respn=data:sub(13):match('([t])":(%d)')
	respn=tonumber(respn)
	if respn==1 then
		print('resp: 1')
		rest=data:sub(13)
		callback(token,length,rest)
	elseif respn==2 then
		print(token)
		print('resp: 2')
		if not buffers[token]then
			buffers[token]=newBuffer('')
		end
		local buffer=buffers[token]
		buffer:add(data:sub(13))
		local func=callbacks[token]or callback
		func(token,#buffer.data,buffer.data)
		buffers[token]=nil
	elseif respn==3 then
		print('resp: 3')
		if not buffers[token]then
			buffers[token]=newBuffer(data:sub(13))
			callbacks[token]=callback
			return
		end
		buffers[token]:add(data:sub(13))
	else
		print('resp: ?')
	end
end
return processor