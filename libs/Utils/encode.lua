local fmt = string.format
local json = require('json')
local protodef = require('./protodef.lua')
local term = protodef.Term
local query = protodef.Query

local queries = {
	continue = fmt('[%s]', query.CONTINUE),
	stop = fmt('[%s]', query.STOP),
	noreplywait = fmt('[%s]', query.NOREPLY_WAIT),
	server_info = fmt('[%s]', query.SERVER_INFO)
}

local function encode(reql)
	if queries[reql.query] then
		return queries[reql.query]
	end
	if reql._table ~= nil and reql._database == nil then
		return error('ReQL table passed to query encoder, no database present.')
	end
	local str = ''
	local db = reql._data.database
	if db then
		str = str .. fmt('[%s, ["%s"]]', term.db, db)
	end
	local tab = reql._data.table
	if tab then
		str = fmt('[%s, [%s, "%s"]]', term.table, str, tab)
	end
	if reql._data.get then
		str = fmt('[%s, [%s, "%s"]]', term.get, str, reql._data.get)
	end
	if reql._data.insert then
		local js=json.encode({term.datum, reql._data.insert})
		str = fmt('[%s, [%s, %s]]', term.insert, str, js)
	end
	if reql._data.replace then
		local js=json.encode({term.datum, reql._data.replace})
		str = fmt('[%s, [%s, %s]]', term.replace, str, js)
	end
	if reql._data.update then
		local js=json.encode({term.datum, reql._data.update})
		str = fmt('[%s, [%s, %s]]', term.update, str, js)
	end
	if reql._data.filter then
		local js=json.encode(reql._data.filter)
		str = fmt('[%s, [%s, %s]]', term.filter, str, js)
	end
	if reql._data.changes then
		str = fmt('[%s, [%s]]', term.changes, str)
	end
	if reql._data.js then
		str = fmt('[%s, ["%s"]]', term.js, reql._data.js)
	end
	if reql._data.table_create then
		str = fmt('[%s, [%s, "%s"]]', term.table_create, reql._data.table_create)
	end
	if reql._data.table_drop then
		str = fmt('[%s, [%s, "%s"]]', term.table_drop, reql._data.table_drop)
	end
	if reql._data.table_list then
		str = fmt('[%s, [%s]]', term.table_list, str)
	end
	if reql._data.db_create then
		str = fmt('[%s, [%s, "%s"]]', term.db_create, reql.data._db_create)
	end
	if reql._data.db_drop then
		str = fmt('[%s, [%s, "%s"]]', term.db_drop, reql.data._db_drop)
	end
	if reql._data.db_list then
		str = fmt('[%s, [%s]]', term.db_list, str)
	end
	if reql._data.delete then
		str = fmt('[%s, [%s]]', term.delete, str)
	end
	if reql._data.index_create then
		str = fmt('[%s, [%s, "%s"]]', term.index_create, reql._data.index_create)
	end
	if reql._data.index_drop then
		str = fmt('[%s, [%s, "%s"]]', term.index_drop, reql._data.index_drop)
	end
	if reql._data.index_list then
		str = fmt('[%s, [%s]]', term.index_list, str)
	end
	if reql._data.get_field then
		str = fmt('[%s, [%s, "%s"]]', term.get_field, str, reql._data.get_field)
	end
	str = '[1,' .. str .. ',{}]'
	return str
end
return encode
