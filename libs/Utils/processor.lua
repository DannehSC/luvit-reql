
local json = require('json')
local intlib = require('./intlib.lua')
local logger = require('./logger.lua')()
local errors = require('../error.lua')

local errcodes = {
	[16] = { type = 'CLIENT_ERROR',  new = errors.ReqlDriverError  },
	[17] = { type = 'COMPILE_ERROR', new = errors.ReqlCompileError },
	[18] = { type = 'RUNTIME_ERROR', new = errors.ReqlRuntimeError },
}

local processor = { cbs = { } }
local buffers = { }

local int = intlib.byte_to_int
function processor.processData(data)
	local token = int(data:sub(1, 8))
    local response_code = tonumber(data:sub(13):match('"t":(%d?%d)'))
    
    if not processor.cbs[token] then
        return logger:warn('invalid token "' .. token .. '", with response code: ' .. response_code)
    end

    local callback = processor.cbs[token]
	if response_code == 1 then
		local json_tbl = data:sub(13)
		local dat      = json_tbl
        
        if dat:find('"r":%[null%]') then
            dat = nil
		elseif not callback.raw then
            local response = json.decode(json_tbl)
            if response then
                dat = response.r
                if callback.isGet then dat = dat[1] end
            else
                callback.conn.logger:warn('bad json: ' .. tostring(json_tbl))
                dat = json_tbl
            end
		end
		callback.conn.logger:debug('response code 1 recieved for token "' .. token .. '"')
        callback.f(dat)
        
		if not callback.keepAlive then processor.cbs[token] = nil end
    elseif response_code == 2 then
		buffers[token] = buffers[token] or { chunks = true, data = { } }
        
		local buffer = buffers[token]
		local decoded = json.decode(data:sub(13))
		for i, v in pairs(decoded.r) do table.insert(buffer.data, v) end
        
		callback.conn.logger:debug('response code 2 recieved for token "' .. token .. '"')
		callback.f(buffer)

		if not callback.keepAlive then
			processor.cbs[token] = nil
        end
        
		buffers[token] = nil
	elseif respn == 3 then
		local conn = callback.conn
        conn.logger:debug('response code 3 recieved for token "' .. token .. '", attempting to continue')
        
		coroutine.wrap(function()
			local query = conn.reql().continue()
			query._data.__overridetoken__ = token
			query.run({ _dont = true })
        end)()
        
        buffers[token] = buffers[token] or { chunks = true, data = { } }
        
		local decoded = json.decode(data:sub(13))
        
		for i, v in pairs(decoded.r) do table.insert(buffers[token].data, v) end
	elseif errcodes[respn] then
		local errcode = errcodes[respn]
        local err     = errcode.new(errcode.type)
        
        conn.logger:warn('Encountered an Error | response code ' .. response_code .. ' recieved for token "' .. token .. '", ' .. tostring(err))
            
        callback.conn.logger:debug('Encoded query: ' .. callback.encoded)
        callback.conn.logger:debug('Line calling reql.run: ' .. callback.caller.currentline)
        callback.f(nil, err, json.decode(data:sub(13)))
        processor.cbs[token] = nil
	else
        conn.logger:warn('response code ' .. tostring(response_code) .. ' recieved for token "' .. token .. '", unknown response')
		if not data then
			data = 'no data?'
		else
			data = data:sub(13)
        end
        
		if callback then
			processor.cbs[token].f(nil, 'unknown response', data)
			processor.cbs[token] = nil
		end
	end
end

return processor
