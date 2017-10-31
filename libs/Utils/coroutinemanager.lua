-- local emitter = require('./emitty.lua')

local manager = {
	threads = {}
}

function manager:isCoro()
	local _, bool = coroutine.running()
	return not bool
end

function manager:yield(id)
	if not manager:isCoro() then return end
	local thread = coroutine.running()
	manager.threads[id]=thread
	return coroutine.yield()
end

function manager:resume(id, ...)
	if not manager.threads[id] then return end
	coroutine.resume(manager.threads[id], ...)
end

return manager
