
local encode = require('./encode.lua')
local processor = require('./processor.lua')

return function(reql, token, callback)
	local validEncode = encode(reql)
	local length = #validEncode
	local data = table.concat({ string.pack('<I8', token), string.pack('<I4', length), validEncode })
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
