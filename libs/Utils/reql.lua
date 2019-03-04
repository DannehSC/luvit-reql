
local logger = require('./logger.lua')
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
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.db = tostring(name)
		return reql
	end
	function reql.table(name)
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.table = tostring(name)
		return reql
	end
	function reql.get(id)
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.get = id
		reql._data.isGet = true
		return reql
	end
	function reql.getField(field)
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.get_field = field
		return reql
	end
	function reql.insert(tab)
		reql.conn.logger:assert(type(tab) == 'table', 'bad argument #1 to reql.insert, table expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.insert = reql._data.insert or {}
		for i, v in pairs(tab) do
			reql._data.insert[i] = v
		end
		return reql
	end
	function reql.js(str)
		reql.conn.logger:assert(type(str) == 'string', 'bad argument #1 to reql.js, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.js = str
		return reql
	end
	function reql.config()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.config = true
		return reql
	end
	function reql.replace(tab)
		reql.conn.logger:assert(type(tab) == 'table', 'bad argument #1 to reql.replace, table expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.replace = reql._data.replace or {}
		for i, v in pairs(tab) do
			reql._data.replace[i] = v
		end
		return reql
	end
	function reql.update(tab)
		reql.conn.logger:assert(type(tab) == 'table', 'bad argument #1 to reql.update, table expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.update = reql._data.update or {}
		for i,v in pairs(tab) do
			reql._data.update[i] = v
		end
		return reql
	end
	function reql.filter(tab)
		reql.conn.logger:assert(type(tab) == 'table', 'bad argument #1 to reql.filter, table expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.filter = reql._data.filter or {}
		for i, v in pairs(tab) do
			reql._data.filter[i] = v
		end
		return reql
	end
	function reql.inOrRe(tab)
		reql.conn.logger:warn('AS OF LUVIT-REQL 1.0.6, inOrRe AND inOrUp ARE DEPRECATED. THEY SHALL BE REMOVED IN V1.0.8 SO PLEASE ADJUST YOUR CODE ACCORDINGLY. NORMAL REPLACE IS THE SAME AS inOrRe.')
		reql.conn.logger:assert(type(tab) == 'table', 'bad argument #1 to reql.inOrRe, table expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql.conn.logger:assert(tab.id ~= nil, 'argument \'id\' not passed to inOrRe')
		reql.conn.logger:assert(cmanager:isCoro(), 'reql.inOrRe not ran in coroutine.')
		reql.get(id).replace(tab)
		return reql
	end
	function reql.inOrUp(tab)
		reql.conn.logger:warn('AS OF LUVIT-REQL 1.0.6, inOrRe AND inOrUp ARE DEPRECATED. THEY SHALL BE REMOVED IN V1.0.8 SO PLEASE ADJUST YOUR CODE ACCORDINGLY.')
		reql.conn.logger:assert(type(tab) == 'table', 'bad argument #1 to reql.inOrUp, table expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql.conn.logger:assert(tab.id ~= nil, 'argument \'id\' not passed to inOrUp')
		reql.conn.logger:assert(cmanager:isCoro(), 'reql.inOrUp not ran in coroutine.')
		local exists = newReql(conn).db(reql._data.db or reql.conn._options.db).table(reql._data.table).get(tab.id).run({ raw = true })
		if exists == nil then
			reql.insert(tab)
		else
			local id = tab.id
			reql.get(id).update(tab)
		end
		return reql
	end
	function reql.changes()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.changes = true
		return reql
	end
	function reql.indexCreate(name)
		reql.conn.logger:assert(type(name) == 'string', 'bad argument #1 to reql.indexCreate, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.index_create = name
		return reql
	end
	function reql.indexDrop(name)
		reql.conn.logger:assert(type(name) == 'string', 'bad argument #1 to reql.indexDrop, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.index_drop = name
		return reql
	end
	function reql.indexList()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.index_list = true
		return reql
	end
	function reql.dbCreate(name)
		reql.conn.logger:assert(type(name) == 'string', 'bad argument #1 to reql.dbCreate, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.db_create = name
		return reql
	end
	function reql.dbDrop(name)
		reql.conn.logger:assert(type(name) == 'string', 'bad argument #1 to reql.dbDrop, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.db_drop = name
		return reql
	end
	function reql.dbList()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.bypass = true
		reql._data.usable = false
		reql._data.db_list = true
		return reql
	end
	function reql.delete()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.delete = true
		return reql
	end
	function reql.tableCreate(name)
		reql.conn.logger:assert(type(name) == 'string', 'bad argument #1 to reql.tableCreate, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.table_create = name
		return reql
	end
	function reql.tableDrop(name)
		reql.conn.logger:assert(type(name) == 'string', 'bad argument #1 to reql.tableDrop, string expected.')
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.table_drop = name
		return reql
	end
	function reql.tableList()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.usable = false
		reql._data.table_list = true
		return reql
	end
	function reql.now()
		reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql._data.bypass = true
		reql._data.usable = false
		reql._data.now = true
		return reql
	end
	function reql.run(tab, callback)
		if type(tab) == 'function' then
			callback = tab
			tab = nil
		end
		tab = tab or { }
		reql.conn.logger:assert(not reql.ran, 'ReQL instance already ran.')
		reql.conn = reql.conn or tab.conn
		reql.conn.logger:assert(reql.conn ~= nil, 'No connection passed to reql.run()')
		reql.conn.logger:assert(not reql.conn._socket.closed, 'Socket closed. Cannot run.')
		reql._data.db = (not reql._data.bypass and (reql._data.db or tab.db or reql.conn._options.db or nil))
		reql._data.table = reql._data.table or tab.table or nil
		reql._data.raw = tab.raw
		local token = reql._data.__overridetoken__ or reql.conn._getToken()
		local x, is = callback, cmanager:isCoro()
		local changes = reql._data.changes
		if is and not changes then
			x = function(...)
				reql.conn.logger:debug('Resuming thread [' .. token .. ']')
				cmanager:resume(token, ...)
				reql.conn.logger:debug('Resumed thread [' .. token.. ']')
			end
		end
		reql.conn.logger:assert(type(x) == 'function', 'bad argument #2 to reql.run(), function expected, got ' .. type(x))
		reql._data.token = token
		reql.caller = debug.getinfo(2)
		processQuery(reql, token, x)
		reql.ran = not reql.conn._options.reusable
		for i in pairs(reql._data) do
			reql._data[i] = nil
		end
		if is and not changes and not tab._dont then
			return cmanager:yield(token)
		end
	end
	for _, v in pairs({ 'continue', 'stop', 'noreplywait', 'server_info' }) do
		reql[v] = function()
			reql.conn.logger:assert(reql._data.usable, 'ReQL instance unusable, please run or start a new instance.')
			reql._data.usable = false
			reql._data.query = v
			return reql
		end
	end
	return reql
end

return function(conn)
	return newReql(conn)
end
