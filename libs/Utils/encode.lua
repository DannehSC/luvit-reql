local fmt=string.format
local protodef=require('./protodef.lua')
local query=protodef.Query
local queries={
	continue=fmt('[%s]',query.CONTINUE),
	stop=fmt('[%s]',query.STOP),
	noreplywait=fmt('[%s]',query.NOREPLY_WAIT),
	server_info=fmt('[%s]',query.SERVER_INFO)
}
local function encode(reql)
	if queries[reql.query]then
		return queries[reql.query]
	end
end
return encode