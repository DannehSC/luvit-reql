local processQuery=require('./query.lua')
function newReql(conn,db)
	local reql={
		ran=false
	}
	if conn then reql.conn=conn end
	function reql.db(name)
		assert(reql.ran,'ReQL instance already ran.')
		reql.setdatabase=name
	end
	function reql.table(name)
		assert(reql.ran,'ReQL instance already ran.')
		reql.settable=name
	end
	function reql.run(tab)
		assert(reql.ran,'ReQL instance already ran.')
		reql.conn=reql.conn or tab.conn
		assert(reql.conn~=nil,'No connection passed to reql.run()')
		reql.setdatabase=reql.setdatabase or tab.db
		reql.settable=reql.settable or tab.table
		processQuery(reql)
		reql.ran=true
	end
	return reql
end
return function(conn)
	return newReql(conn)
end