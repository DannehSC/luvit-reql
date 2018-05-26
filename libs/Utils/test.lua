
local uv = require('uv')
local ssl = require('openssl')
local pp = require('pretty-print')

local cg = collectgarbage
local fmt = string.format
local hrtime = uv.hrtime

local NS_PER_US = 1000
local US_PER_MS = 1000
local NS_PER_MS = NS_PER_US * US_PER_MS

local function getMem()
	local mem = cg('count')
	local tab = {
		kb = 0,
		mb = 0,
		gb = 0,
	}
	if mem > 1000 then
		tab.mb = mem / 1000
		tab.kb = mem - (tab.mb * 1000)
		if tab.mb > 1000 then
			tab.gb = tab.mb / 1000
			tab.mb = mem - (tab.gb * 1000)
		end
	else
		tab.kb = mem
	end
	return tab
end

return function(conn)
	local started = uv.hrtime()
	conn.logger:info('Starting 2000 query stress test')
	local startingMem = getMem()
	local reql = conn.reql
	local name = ssl.base64(ssl.random(40)):gsub('=',''):gsub('/',''):gsub('+','')
	reql().dbCreate(name).run()
	reql().db(name).tableCreate('table').run()
	for i = 1,1000 do
		reql().db(name).table('table').insert({
			id = i * i,
			test = 'wow'
		}).run()
	end
	for i = 1,1000 do
		reql().db(name).table('table').get(i * i).run()
	end
	reql().dbDrop(name).run()
	local endMem = getMem()
	local ended = uv.hrtime()
	conn.logger:info(fmt('\nTest took: %s\n\nMem before testing:\nGB: %s\nMB: %s\nKB: %s\n\nMem post testing:\nGB: %s\nMB: %s\nKB: %s',
		((ended - started) / NS_PER_MS),startingMem.gb,startingMem.mb,startingMem.kb,endMem.gb,endMem.mb,endMem.kb
	))
end