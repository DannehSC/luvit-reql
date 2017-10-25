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
		local js=json.encode({term.datum,reql._insert})
		str=fmt('[%s, [%s, %s]]',term.insert,str,js)
	end
	if reql._replace then
		local js=json.encode({term.datum,reql._replace})
		str=fmt('[%s, [%s, %s]]',term.replace,str,js)
	end
	if reql._update then
		local js=json.encode({term.datum,reql._update})
		str=fmt('[%s, [%s, %s]]',term.update,str,js)
	end
	if reql._filter then
		local js=json.encode(reql._filter)
		str=fmt('[%s, [%s, %s]]',term.filter,str,js)
	end
	if reql._js then
		str=fmt('[%s, ["%s"]]',term.js,reql._js)
	end
	if reql._table_create then
		str=fmt('[%s, [%s, "%s"]]',term.table_create,reql._table_create)
	end
	if reql._table_drop then
		str=fmt('[%s, [%s, "%s"]]',term.table_drop,reql._table_drop)
	end
	if reql._table_list then
		str=fmt('[%s, [%s]]',term.table_list,str)
	end
	if reql._db_create then
		str=fmt('[%s, [%s, "%s"]]',term.db_create,reql._db_create)
	end
	if reql._db_drop then
		str=fmt('[%s, [%s, "%s"]]',term.db_drop,reql._db_drop)
	end
	if reql._db_list then
		str=fmt('[%s, [%s]]',term.db_list,str)
	end
	if reql._delete then
		str=fmt('[%s, [%s]]',term.delete,str)
	end
	if reql._index_create then
		str=fmt('[%s, [%s, "%s"]]',term.index_create,reql._index_create)
	end
	if reql._index_drop then
		str=fmt('[%s, [%s, "%s"]]',term.index_drop,reql._index_drop)
	end
	if reql._index_list then
		str=fmt('[%s, [%s]]',term.index_list,str)
	end
	if reql._get_field then
		str=fmt('[%s, [%s, "%s"]]',term.get_field,str,reql._get_field)
	end
	str='[1,'..str..',{}]'
	return str
end
return encode