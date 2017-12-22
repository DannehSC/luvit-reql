
local running, yield, resume = coroutine.running, coroutine.yield, coroutine.resume

local manager = {
	threads = {}
}

function manager:isCoro()
	local _, bool = running()
	return not bool
end

function manager:yield(id)
	if not manager:isCoro() then return end
	local thread = running()
	manager.threads[id] = thread
	return yield()
end

function manager:resume(id, ...)
	if not manager.threads[id] then return end
	resume(manager.threads[id], ...)
end

return manager
