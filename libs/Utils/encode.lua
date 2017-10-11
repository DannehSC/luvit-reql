local fmt=string.format
local json=require('json')
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
	if reql._table~=nil and reql._database==nil then
		error('ReQL table passed to query encoder, no database present.')
	end
	local str=''
	local db=reql._database
	if db then
		str=str..fmt('[%s, ["%s"]]',term.db,db)
	end
	local tab=reql._table
	if tab then
		str=fmt('[%s, [%s, "%s"]]',term.table,str,tab)
	end
	if reql._get then
		str=fmt('[%s, [%s, "%s"]]',term.get,str,reql._get)
	end
	if reql._insert then
		local js=json.encode(reql._insert)
		str=fmt('[%s, [%s, %s]]',term.insert,str,js)
	end
	if reql._replace then
		local js=json.encode(reql._replace)
		str=fmt('[%s, [%s, %s]]',term.replace,str,js)
	end
	if reql._update then
		local js=json.encode(reql._update)
		str=fmt('[%s, [%s, %s]]',term.update,str,js)
	end
	if reql._js then
		str=fmt('[%s, ["%s"]]',term.js,reql._js)
	end
	str='[1,'..str..',{}]'
	p(str)
	return str
end
return encode