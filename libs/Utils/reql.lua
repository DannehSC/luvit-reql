local processQuery=require('./query.lua')
function newReql(conn,db)
	local reql={
		ran=false,
		usable=true
	}
	if conn then reql.conn=conn end
	function reql.db(name)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.setdatabase=name
		return reql
	end
	function reql.table(name)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.settable=name
		return reql
	end
	function reql.get(id)
		assert(reql.usable,'ReQL instance unusable, please run or start a new instance.')
		assert(not reql.ran,'ReQL instance already ran.')
		reql.setget=id
		return reql
	end
	function reql.run(tab)
		tab=tab or{}
		assert(not reql.ran,'ReQL instance already ran.')
		reql.conn=reql.conn or tab.conn
		assert(reql.conn~=nil,'No connection passed to reql.run()')
		reql.setdatabase=reql.setdatabase or tab.db
		reql.settable=reql.settable or tab.table
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