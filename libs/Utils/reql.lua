local json=require('json')
local processQuery=require('./query.lua')
local cmanager=require('./coroutinemanager.lua')
local newReql
function newReql(conn)
	local reql={
		ran=false,
		usable=true
	}
	if conn then reql.conn=conn end
	function reql.db(name)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._database=tostring(name)
		return reql
	end
	function reql.table(name)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._table=tostring(name)
		return reql
	end
	function reql.get(id)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._get=id
		return reql
	end
	function reql.getField(field)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._get_field=id
		return reql
	end
	function reql.insert(tab)
		assert(type(tab)=='table','bad argument #1 to reql.insert, table expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._insert=reql._insert or{}
		for i,v in pairs(tab)do
			reql._insert[i]=v
		end
		return reql
	end
	function reql.js(str)
		assert(type(str)=='string','bad argument #1 to reql.js, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._js=str
		return reql
	end
	function reql.replace(tab)
		assert(type(tab)=='table','bad argument #1 to reql.replace, table expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._replace=reql._replace or{}
		for i,v in pairs(tab)do
			reql._replace[i]=v
		end
		return reql
	end
	function reql.update(tab)
		assert(type(tab)=='table','bad argument #1 to reql.update, table expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._update=reql._update or{}
		for i,v in pairs(tab)do
			reql._update[i]=v
		end
		return reql
	end
	function reql.filter(tab)
		assert(type(tab)=='table','bad argument #1 to reql.filter, table expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._filter=reql._filter or{}
		for i,v in pairs(tab)do
			reql._filter[i]=v
		end
		return reql
	end
	function reql.inOrRe(tab)
		assert(type(tab)=='table','bad argument #1 to reql.inOrRe, table expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		--assert(tab.id~=nil,'argument \'id\' not passed to inOrRe')
		assert(cmanager:isCoro(),'reql.inOrRe not ran in coroutine.')
		local exists=newReql(conn).db(reql._database).table(reql._table).get(tab.id).run({raw=true})
		if exists==nil or exists==json.null or exists[1]==nil then
			reql.replace(tab)
		else
			reql.insert(tab)
		end
		return reql
	end
	function reql.inOrUp(tab)
		assert(type(tab)=='table','bad argument #1 to reql.inOrUp, table expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		--assert(tab.id~=nil,'argument \'id\' not passed to inOrUp')
		assert(cmanager:isCoro(),'reql.inOrUp not ran in coroutine.')
		local exists=newReql(conn).db(reql._database).table(reql._table).get(tab.id).run({raw=true})
		if exists==nil or exists==json.null or exists[1]==nil then
			reql.update(tab)
		else
			reql.insert(tab)
		end
		return reql
	end
	function reql.indexCreate(name)
		assert(type(name)=='string','bad argument #1 to reql.indexCreate, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._index_create=name
		return reql
	end
	function reql.indexDrop(name)
		assert(type(name)=='string','bad argument #1 to reql.indexDrop, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._index_drop=name
		return reql
	end
	function reql.indexList()
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._index_list=true
		return reql
	end
	function reql.dbCreate(name)
		assert(type(name)=='string','bad argument #1 to reql.dbCreate, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._db_create=name
		return reql
	end
	function reql.dbDrop(name)
		assert(type(name)=='string','bad argument #1 to reql.dbDrop, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._db_drop=name
		return reql
	end
	function reql.dbList()
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._db_list=true
		return reql
	end
	function reql.delete()
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._delete=true
		return reql
	end
	function reql.tableCreate(name)
		assert(type(name)=='string','bad argument #1 to reql.tableCreate, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._table_create=name
		return reql
	end
	function reql.tableDrop(name)
		assert(type(name)=='string','bad argument #1 to reql.tableDrop, string expected.')
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._table_drop=name
		return reql
	end
	function reql.tableList()
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.usable=false
		reql._table_list=true
		return reql
	end
	function reql.run(tab,callback)
		if type(tab)=='function'then
			callback=tab
			tab=nil
		end
		tab=tab or{}
		assert(not reql.ran,'ReQL instance already ran.')
		reql.conn=reql.conn or tab.conn
		assert(reql.conn~=nil,'No connection passed to reql.run()')
		assert(not reql.conn._socket.closed,'Socket closed. Cannot run.')
		reql._database=reql._database or tab.db or nil
		reql._table=reql._table or tab.table or nil
		local token=reql.conn._getToken()
		local x,is=callback,cmanager:isCoro()
		if is then
			x=function(...)
				cmanager:resume(token,...)
			end
		end
		assert(type(x)=='function','bad argument #2 to reql.run, function expected, got '..type(x))
		processQuery(reql,token,x)
		reql.ran=true
		if is then
			return cmanager:yield(token)
		end
	end
	for i,v in pairs({'continue','stop','noreplywait','server_info'})do
		reql[v]=function()
			assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
			reql.usable=false
			reql.query=v
			return reql
		end
	end
	return reql
end
return function(conn)
	return newReql(conn)
end