--will send ReQL queries to the server
local encode=require('./encode.lua')
return function(reql)
	local validEncode=encode(reql)
	
end