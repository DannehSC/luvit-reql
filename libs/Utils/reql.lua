local processQuery=require('./query.lua')
function newReql(conn,db)
	local reql={}
	if conn then reql.defaultConn=conn end
	function reql.db(name)
		reql.database=name
	end
	function reql.table(name)
		reql.table=name
	end
	function reql.run(tab)
		if not reql.defaultConn and not tab.conn then
			error'No connection provided to reql.run()'
		end
		if not reql.database and not tab.db then
			error'No database provided to reql.run()'
		end
		if not reql.table and not tab.table then
			error'No table provided to reql.run()'
		end
		local conn,db,table=(reql.defaultConn or tab.conn),(reql.database or tab.db),(reql.table or tab.table)
		--processQuery(conn,db,table,reql)
	end
	return reql
end
return function(conn)
	return newReql(conn)
end