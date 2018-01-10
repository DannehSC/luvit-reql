
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

local functions = {
	function(n, _, data)
		return fmt('[%s, ["%s"]]', term[n], data)
	end,
	function(n, data, f1)
		return fmt('[%s, [%s, "%s"]]', term[n], data, f1)
	end,
	function(n, data, f1)
		return fmt('[%s, [%s, %s]]', term[n], data, f1)
	end,
	function(n, data)
		return fmt('[%s, [%s]]', term[n], data)
	end,
	function(n, _, data)
		return fmt('[%s, [%s]]', term[n], data)
	end
}

local index = {
	'table',
	'get',
	'insert',
	'config',
	'update',
	'replace',
	'filter',
	'changes',
	'js',
	'table_create',
	'table_drop',
	'table_list',
	'db_create',
	'db_delete',
	'db_list',
	'index_create',
	'index_delete',
	'index_list',
	'delete',
	'get_field',
	'now'
}

local references = {
 --	database =     { f = functions[1], t = term.db           },
	table =        { f = functions[2], t = term.table        },
	get =          { f = functions[2], t = term.get          },
	config =       { f = functions[4], t = term.config       },
	insert =       { f = functions[3], t = term.insert,      jsDatum = true, json = true },
	update =       { f = functions[3], t = term.update,      jsDatum = true, json = true },
	replace =      { f = functions[3], t = term.replace,     jsDatum = true, json = true },
	filter =       { f = functions[3], t = term.filter,      json = true     },
	changes =      { f = functions[4], t = term.changes      },
	js =           { f = functions[1], t = term.changes      },
	table_create = { f = functions[2], t = term.table_create },
	table_drop =   { f = functions[2], t = term.table_drop   },
	table_list =   { f = functions[4], t = term.table_list   },
	db_create =    { f = functions[2], t = term.db_create    },
	db_drop =      { f = functions[2], t = term.db_drop      },
	db_list =      { f = functions[4], t = term.db_list      },
	index_create = { f = functions[2], t = term.index_create },
	index_drop =   { f = functions[2], t = term.index_drop   },
	index_list =   { f = functions[4], t = term.index_list   },
	delete =       { f = functions[4], t = term.delete       },
	get_field =    { f = functions[2], t = term.get_field    },
	now =          { f = functions[4], t = term.now          }
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
	local js
	for i = 1, #index do
		local v = index[i]
		local dat = reql._data[v]
		if dat then
			local ref = references[v]
			if ref then
				if ref.json == true then
					if ref.jsDatum == true then
						js = json.encode({term.datum, dat})
					else
						js = json.encode(dat)
					end
				else
					js = dat
				end
				str = ref.f(v, str, js)
			end
		end
	end
	str = '[1, ' .. str .. ', {}]'
	return str
end
return encode
