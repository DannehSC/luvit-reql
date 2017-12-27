--will send ReQL queries to the server
local encode = require('Utils/encode')
local intlib = require('Utils/intlib')
local processor = require('Utils/processor')
local bytes = intlib.int_to_bytes

return function(reql, token, callback)
	local validEncode = encode(reql)
	local length = #validEncode
	local data = table.concat({bytes(token, 8), bytes(length, 4), validEncode})
	reql.conn._socket.write(data)
	processor.cbs[token] = { f = callback, raw = reql._data.raw, keepAlive = reql._data.changes, getterWetter = reql._data.megaSuperGetData }
end
