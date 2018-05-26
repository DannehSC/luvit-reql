
local uv = require('uv')
local ssl = require('openssl')
local pp = require('pretty-print')

local cg = collectgarbage
local fmt = string.format
local hrtime = uv.hrtime

local S_PER_MIN = 60
local MS_PER_S = 1000
local US_PER_MS = 1000
local NS_PER_US = 1000

local NS_PER_MS = NS_PER_US * US_PER_MS
local NS_PER_S = NS_PER_MS * MS_PER_S
local NS_PER_MIN = NS_PER_MS * MS_PER_S * S_PER_MIN

local modf, fmod = math.modf, math.fmod

local MB_PER_GB = 1024
local KB_PER_MB = 1024
local B_PER_KB = 1024

local B_PER_MB = B_PER_KB * KB_PER_MB
local B_PER_GB = B_PER_MB * MB_PER_GB

local memfmt = '%s GB %s MB %s KB %s B'
local function getMem()
	local mem = cg('count') * B_PER_KB

	return memfmt:format(modf(mem / B_PER_GB), modf(fmod(mem / B_PER_MB, MB_PER_GB)), modf(fmod(mem / B_PER_KB, KB_PER_MB)), modf(fmod(mem, B_PER_KB)))
end

local timefmt = '%s min %s sec %s ms %s us %s ns'
local function normalize_ms(ns)
	return timefmt:format(modf(ns / NS_PER_MIN), modf(fmod(ns / NS_PER_S, S_PER_MIN)), modf(fmod(ns / NS_PER_MS, MS_PER_S)), modf(fmod(ns / NS_PER_US, US_PER_MS)), modf(fmod(ns, NS_PER_US)))
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
	conn.logger:info(fmt('\nTest Took:    %s\nPre Testing:  %s\nPost Testing: %s', normalize_ms(ended - started), startingMem, endMem))
end