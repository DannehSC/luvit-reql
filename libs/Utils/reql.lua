function newReql(conn)
	local reql={}
	if conn then reql.defaultConn=conn end
	
	return reql
end
return function(conn)
	return newReql(conn)
end