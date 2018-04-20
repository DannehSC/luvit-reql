
local json = require('json')
local intlib = require('./intlib.lua')
local logger = require('./logger.lua')
local errors = require('../error.lua')

local errcodes = {
	[16] = { t = 'CLIENT_ERROR', f = errors.ReqlDriverError },
	[17] = { t = 'COMPILE_ERROR', f = errors.ReqlCompileError },
	[18] = { t = 'RUNTIME_ERROR', f = errors.ReqlRuntimeError },
}
local processor = { cbs = {} }

local buffers = {}

local int = intlib.byte_to_int
function processor.processData(data)
	local token = int(data:sub(1,8))
	local respn = data:sub(13):match('"t":(%d?%d)')
	respn = tonumber(respn)
	if respn == 1 then
		local rest = data:sub(13)
		local dat
		local todat = processor.cbs[token]
		if not todat then
			logger.warn('Invalid data token, resp code: '..respn)
			return
		end
		if todat.raw then
			dat = rest
			if dat:find('%"r%"%:%[null%]') then
				dat = nil
			end
		else
			if rest:find('%"r%"%:%[null%]') then
				dat = nil
			else
				local theresp = json.decode(rest)
				if theresp then
					dat = theresp.r
					if todat.getterWetter then
						dat = dat[1]
					end
				else
					logger.warn(string.format('Bad JSON: %s', rest))
					dat = rest
				end
			end
		end
		if todat.conn._options.debug then
			logger.debug('Response num 1 received.')
		end
		todat.f(dat)
		if not todat.keepAlive then
			processor.cbs[token] = nil
		end
	elseif respn == 2 then
		if not buffers[token] then
			buffers[token] = {
				chunks = true,
				data = {},
			}
		end
		local buffer = buffers[token]
		for i,v in pairs(json.decode(data:sub(13)).r) do
			table.insert(buffer.data, v)
		end
		local dat
		local todat = processor.cbs[token]
		if not todat then 
			logger.warn('Invalid data token, resp code: '..respn)
			return
		end
		if todat.conn._options.debug then
			logger.debug('Response num 2 received.')
		end
		todat.f(buffer)
		if todat.conn._options.debug then
			logger.debug('Response num 2 fired function.')
		end
		if not todat.keepAlive then
			processor.cbs[token] = nil
		end
		buffers[token] = nil
	elseif respn == 3 then
		local conn = processor.cbs[token].conn
		if conn._options.debug then
			logger.debug('Response num 3 received. Attempting to continue.')
		end
		coroutine.wrap(function()
			local query = conn.reql().continue()
			query._data.__overridetoken__ = token
			query.run({_dont = true})
		end)()
		local tab = json.decode(data:sub(13))
		if not buffers[token] then
			buffers[token] = {
				chunks = true,
				data = {}
			}
		end
		for i,v in pairs(tab.r) do
			table.insert(buffers[token].data, v)
		end
	elseif errcodes[respn] then
		local ec = errcodes[respn]
		local err = ec.f(ec.t)
		logger.warn('Error encountered. Error code: ' .. respn .. ' | Error info: ' .. tostring(err))
		if processor.cbs[token]then
			local d = processor.cbs[token]
			if d.conn._options.debug then
				logger.debug('Encoded query: ' .. d.encoded)
				logger.debug('Line calling reql.run: ' .. d.caller.currentline)
			end
			d.f(nil, err, json.decode(data:sub(13)))
			processor.cbs[token] = nil
		end
	else
		logger.warn(string.format('Unknown response: %s', tostring(respn)))
		if not data then
			data = 'no data?'
		else
			data = data:sub(13)
		end
		processor.cbs[token].f(nil, 'Unknown response', data)
		processor.cbs[token] = nil
	end
end
return processor
