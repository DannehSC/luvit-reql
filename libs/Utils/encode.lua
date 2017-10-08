local fmt=string.format
local protodef=require('./protodef.lua')
local term=protodef.Term
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
	assert(reql.settable and reql.setdatabase~=nil,'ReQL table passed to query encoder, no database present.')
	local str=''
	local db=reql.setdatabase
	str=str..fmt('[%s, ["%s"]]',term.db,db)
	local tab=reql.settable
	str=fmt('[%s, [%s, "%s"]]',term.table,str,tab)
	if reql.setget then
		str=fmt('[%s, [%s, "%s"]]',term.get,str,reql.setget)
		print(str)
	end
	str='[1,'..str..',{}]'
	return str
end
return encode