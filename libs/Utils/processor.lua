local json = require('json')
local intlib = require('./intlib.lua')
local logger = require('./logger.lua')
local errors = require('../error.lua')
-- local cmanager = require('./coroutinemanager.lua')

local errcodes = {
	[16] = {t = 'CLIENT_ERROR',f = errors.ReqlDriverError},
	[17] = {t = 'COMPILE_ERROR',f = errors.ReqlCompileError},
	[18] = {t = 'RUNTIME_ERROR',f = errors.ReqlRuntimeError},
}
local processor = {
	cbs = {},
}

local buffers = {}
local function newBuffer(tx)
	local buffer = {data = tx}
	function buffer:add(tx)
		buffer.data = buffer.data .. tx
	end
	return buffer
end

local int = intlib.byte_to_int
function processor.processData(data)
	local token = int(data:sub(1,8))
	local length = int(data:sub(9,12)) -- NOTE: unused variable
	local resp = data:sub(13) -- NOTE: unused variable
	local t, respn = data:sub(13):match('([t])":(%d?%d)') -- NOTE: unused variable
	respn = tonumber(respn)
	if respn == 1 then
		local rest = data:sub(13)
		local dat
		local todat = processor.cbs[token]
		if not todat then return end
		if todat.raw then
			dat = rest
			if dat:find('%"r%"%:%[null%]')then
				dat = nil
			end
		else
			local theresp=json.decode(rest)
			if theresp then
				dat=theresp.r
			else
				logger.warn(string.format('Bad JSON: %s', rest))
				dat=rest
			end
		end
		todat.f(dat)
		if not todat.keepAlive then
			processor.cbs[token] = nil
		end
	elseif respn == 2 then
		if not buffers[token]then
			buffers[token] = newBuffer('')
		end
		local buffer = buffers[token]
		buffer:add(data:sub(13))
		local dat
		local todat = processor.cbs[token]
		if not todat then return end
		if todat.raw then
			dat=buffer.data
			if dat:find('%"r%"%:%[null%]')then
				dat = nil
			end
		else
			local theresp=json.decode(buffer.data)
			if theresp then
				dat=theresp.r
			else
				logger.warn(string.format('Bad JSON: %s',buffer.data))
				dat=buffer.data
			end
		end
		todat.f(dat)
		if not todat.keepAlive then
			processor.cbs[token] = nil
		end
		buffers[token] = nil
	elseif respn == 3 then
		if not buffers[token]then
			buffers[token] = newBuffer(data:sub(13))
			return
		end
		buffers[token]:add(data:sub(13))
	elseif errcodes[respn]then
		local ec = errcodes[respn]
		local err = ec.f(ec.t)
		logger.warn('Error encountered. Error code: ' .. respn .. ' | Error info: ' .. tostring(err))
		if processor.cbs[token]then
			processor.cbs[token].f(nil, err, json.decode(data:sub(13)))
			processor.cbs[token] = nil
		end
	else
		logger.warn(string.format('Unknown response: %s', respn))
	end
end
return processor
