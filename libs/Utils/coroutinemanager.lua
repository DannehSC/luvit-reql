
local running, yield, resume = coroutine.running, coroutine.yield, coroutine.resume

local manager = {
	threads = { }
}

function manager:isCoro()
	local thread, main = running()
	return not main
end

function manager:yield(id)
	if not self:isCoro() then return end
	local thread = running()
	self.threads[id] = thread
	return yield()
end

function manager:resume(id, ...)
	if not self.threads[id] then return end
	assert(resume(self.threads[id], ...))
end

return manager
