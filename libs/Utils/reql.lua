-- local json = require('json')
local processQuery = require('./query.lua')
local cmanager = require('./coroutinemanager.lua')

local newReql
function newReql(conn)
	local reql = {
		ran = false,
		_data = {
			usable = true
		}
	}
	if conn then reql.conn = conn end
	function reql.db(name)
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.database = tostring(name)
		return reql
	end
	function reql.table(name)
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.table = tostring(name)
		return reql
	end
	function reql.get(id)
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.get = id
		reql._data.megaSuperGetData = true
		return reql
	end
	function reql.getField(field)
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.get_field = field
		return reql
	end
	function reql.insert(tab)
		assert(type(tab) == 'table', 'bad argument #1 to reql.insert, table expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.insert = reql._data.insert or {}
		for i, v in pairs(tab) do
			reql._data.insert[i] = v
		end
		return reql
	end
	function reql.js(str)
		assert(type(str) == 'string', 'bad argument #1 to reql.js, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.js = str
		return reql
	end
	function reql.replace(tab)
		assert(type(tab) == 'table', 'bad argument #1 to reql.replace, table expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.replace = reql._data.replace or {}
		for i, v in pairs(tab) do
			reql._data.replace[i] = v
		end
		return reql
	end
	function reql.update(tab)
		assert(type(tab) == 'table', 'bad argument #1 to reql.update, table expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.update = reql._data.update or {}
		for i,v in pairs(tab) do
			reql._data.update[i] = v
		end
		return reql
	end
	function reql.filter(tab)
		assert(type(tab) == 'table', 'bad argument #1 to reql.filter, table expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.filter = reql._data.filter or {}
		for i, v in pairs(tab) do
			reql._data.filter[i] = v
		end
		return reql
	end
	function reql.inOrRe(tab)
		assert(type(tab) == 'table', 'bad argument #1 to reql.inOrRe, table expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		assert(tab.id ~= nil, 'argument \'id\' not passed to inOrRe')
		assert(cmanager:isCoro(), 'reql.inOrRe not ran in coroutine.')
		local exists = newReql(conn).db(reql._data.database or reql.conn._options.db).table(reql._data.table).get(tab.id).run({ raw = true })
		if exists == nil then
			reql.insert(tab)
		else
			local id = tab.id
			--tab.id=nil
			reql.get(id).replace(tab)
		end
		return reql
	end
	function reql.inOrUp(tab)
		assert(type(tab) == 'table', 'bad argument #1 to reql.inOrUp, table expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		assert(tab.id ~= nil, 'argument \'id\' not passed to inOrUp')
		assert(cmanager:isCoro(), 'reql.inOrUp not ran in coroutine.')
		local exists = newReql(conn).db(reql._data.database or reql.conn._options.db).table(reql._data.table).get(tab.id).run({ raw = true })
		if exists == nil then
			reql.insert(tab)
		else
			local id = tab.id
			tab.id = nil
			reql.get(id).update(tab)
		end
		return reql
	end
	function reql.changes()
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.changes = true
		return reql
	end
	function reql.indexCreate(name)
		assert(type(name) == 'string', 'bad argument #1 to reql.indexCreate, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.index_create = name
		return reql
	end
	function reql.indexDrop(name)
		assert(type(name) == 'string', 'bad argument #1 to reql.indexDrop, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.index_drop = name
		return reql
	end
	function reql.indexList()
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.index_list = true
		return reql
	end
	function reql.dbCreate(name)
		assert(type(name) == 'string', 'bad argument #1 to reql.dbCreate, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.db_create = name
		return reql
	end
	function reql.dbDrop(name)
		assert(type(name) == 'string', 'bad argument #1 to reql.dbDrop, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.db_drop = name
		return reql
	end
	function reql.dbList()
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.bypass = true
		reql._data.usable = false
		reql._data.db_list = true
		return reql
	end
	function reql.delete()
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.delete = true
		return reql
	end
	function reql.tableCreate(name)
		assert(type(name) == 'string', 'bad argument #1 to reql.tableCreate, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.table_create = name
		return reql
	end
	function reql.tableDrop(name)
		assert(type(name) == 'string', 'bad argument #1 to reql.tableDrop, string expected.')
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.table_drop = name
		return reql
	end
	function reql.tableList()
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.table_list = true
		return reql
	end
	function reql.now()
		assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.bypass = true
		reql._data.usable = false
		reql._data.now = true
		return reql
	end
	function reql.run(tab, callback)
		if type(tab) == 'function'then
			callback = tab
			tab = nil
		end
		tab= tab or {}
		assert(not reql.ran, 'ReQL instance already ran.')
		reql.conn = reql.conn or tab.conn
		assert(reql.conn ~= nil, 'No connection passed to reql.run()')
		assert(not reql.conn._socket.closed, 'Socket closed. Cannot run.')
		reql._data.database = (not reql._data.bypass and (reql._data.database or tab.db or reql.conn._options.db or nil))
		reql._data.table = reql._data.table or tab.table or nil
		reql._data.raw = tab.raw
		local token = reql.conn._getToken()
		local x, is = callback, cmanager:isCoro()
		if is and not reql._data.changes then
			x = function(...)
				cmanager:resume(token,...)
			end
		end
		assert(type(x) == 'function', 'bad argument #2 to reql.run(), function expected, got ' .. type(x))
		processQuery(reql, token, x)
		reql.ran = not reql.conn._options.reusable
		for i in pairs(reql._data) do
			reql._data[i] = nil
		end
		if is then
			return cmanager:yield(token)
		end
	end
	for _, v in pairs({ 'continue', 'stop', 'noreplywait', 'server_info' })do
		reql[v] = function()
			assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
			reql._data.usable = false
			reql.query = v
			return reql
		end
	end
	return reql
end
return function(conn)
	return newReql(conn)
end
