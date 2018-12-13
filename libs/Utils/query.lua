
local encode = require('./encode.lua')
local intlib = require('./intlib.lua')
local processor = require('./processor.lua')
local bytes = intlib.int_to_bytes

return function(reql, token, callback)
	local validEncode = encode(reql)
	local length = #validEncode
	local data = table.concat({ bytes(token, 8), bytes(length, 4), validEncode })
	reql.conn.logger:debug(string.format('Sending query (Token: %s, length: %s) with data: %s', token, length, validEncode))
    
	processor.cbs[token] = { 
		f = callback, 
		raw = reql._data.raw, 
		keepAlive = reql._data.changes, 
		isGet = reql._data.isGet, 
		conn = reql.conn, 
		encoded = validEncode, 
		caller = reql.caller 
    }
    
    reql.conn._socket.write(data)
end
