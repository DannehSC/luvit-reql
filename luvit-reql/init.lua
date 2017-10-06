local connect=require('./connect.lua')
local reql=require('./Utils/reql.lua')
--Do not edit the default table, pass them to the returned function.
local default={
	--Access--
	address='http://127.0.0.1/',
	port=28015,
	--Security related stuff--
	user='admin',
	password='',
	--Convenience--
	db='test',
}
return {
	connect=function(tab)
		if tab==nil then tab={}end
		if type(tab)~='table'then error("Bad argument #1 to think-luvit/init.lua, table expected, got "..type(tab))end
		for i,v in pairs(default)do
			if not tab[i]then
				tab[i]=v
			end
		end
		if tab.address:sub(#tab.address)~='/'then
			tab.address=tab.address..'/'
		end
		if tab.address:sub(1,5)~='https'and tab.address:sub(1,4)~='http'then	
			print('[WARNING] Procotol not supplied, defaulting to http://')
			tab.address='http://'..tab.address
		end
		return connect(tab)
	end,
	reql=reql()
}