
local ssl = require('openssl')
local timer = require('timer')
local cmanager = require('./coroutinemanager.lua')

local emitter = {
	callbacks = {}
}

local function getId()
	return ssl.base64(ssl.random(20), true)
end

function emitter:on(event, callback)
	local id = getId()
	emitter.callbacks[id] = {
		event = event,
		callback = callback,
	}
	return id
end

function emitter:once(event, callback)
	local id
	id = emitter:on(event, function(...)
		emitter:del(id)
		callback(...)
	end)
	return id
end

function emitter:del(id)
	if emitter.callbacks[id] then
		emitter.callbacks[id] = nil
	end
end

function emitter:fire(event,...)
	for _, v in pairs(emitter.callbacks)do
		if v.event:lower() == event then
			v.callback(...)
		end
	end
end

function emitter:waitFor(event,timeout)
	local id = getId()
	local eid
	if timeout then
		coroutine.wrap(function()
			timer.setTimeout(timeout,function()
				eid:del(id)
				cmanager:resume(id)
			end)
		end)()
	end
	eid = emitter:once(event,function()
		cmanager:resume(id)
	end)
	return cmanager:yield(id)
end

return emitter
