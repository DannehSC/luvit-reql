
local logger = require('./logger.lua')
local encode = require('./encode.lua')
local intlib = require('./intlib.lua')
local processor = require('./processor.lua')
local bytes = intlib.int_to_bytes

return function(reql, token, callback)
	local validEncode = encode(reql)
	local length = #validEncode
	local data = table.concat({ bytes(token, 8), bytes(length, 4), validEncode })
	if reql.conn._options.debug then
		logger.debug(string.format('Sending query (Token: %s, length: %s) with data: %s', token, length, validEncode))
	end
	reql.conn._socket.write(data)
	processor.cbs[token] = { 
		f = callback, 
		raw = reql._data.raw, 
		keepAlive = reql._data.changes, 
		getterWetter = reql._data.megaSuperGetData, 
		conn = reql.conn, 
		encoded = validEncode, 
		caller = reql.caller 
	}
	if not processor.cbs[token] then
		logger.warn("Possible problem detected. Monitor for coroutine freezing.")
	end
end
