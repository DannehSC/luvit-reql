local processQuery=require('./query.lua')
function newReql(conn)
	local reql={
		ran=false,
		usable=true
	}
	if conn then reql.conn=conn end
	function reql.db(name)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._database=name
		return reql
	end
	function reql.table(name)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._table=name
		return reql
	end
	function reql.get(id)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql._get=id
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
		assert(type(str)=='string','bad argument #1 to reql.insert, string expected.')
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
	function reql.run(tab)
		tab=tab or{}
		assert(not reql.ran,'ReQL instance already ran.')
		reql.conn=reql.conn or tab.conn
		assert(reql.conn~=nil,'No connection passed to reql.run()')
		reql._database=reql._database or tab.db or nil
		reql._table=reql._table or tab.table or nil
		processQuery(reql)
		reql.ran=true
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