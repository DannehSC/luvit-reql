local ssl = require('openssl')

local emitter = {
	callbacks = {}
}

function emitter:on(event, callback)
	local id = ssl.base64(ssl.random(20), true)
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

return emitter
