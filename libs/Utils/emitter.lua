
local timer = require('timer')

local emitter = { listeners = { } }

function emitter:on(event, listener, sync)
	if not self.listeners[event] then self.listeners[event] = { } end
	
	table.insert(self.listeners[event], { fn = listener, sync = sync })
	
	return listener
end

function emitter:once(event, listener, sync)
	if not self.listeners[event] then self.listeners[event] = { } end
	
	table.insert(self.listeners[event], { fn = listener, once = true, sync = sync })
	
	return listener
end

function emitter:listenerCount(event)
	if event then
		local listeners = self.listeners[event]
		if not listeners then return 0 end
		local n = 0

		for _ in ipairs(listeners) do
			n = n + 1
		end

		return n
	else
		local n = 0

		for e in pairs(self.listeners) do
			n = n + self:listenerCount(e)
		end

		return n
	end
end

function emitter:remove(event, listener)
	local listeners = self.listeners[event]
	if not listeners then return end

	for i, f in next, listeners do
		if f == listener.fn then
			table.remove(listeners, i)
		end
	end
end

function emitter:removeAll(event)
	self.listeners[event] = nil
end

function emitter:fire(event, ...)
	local listeners = self.listeners[name]
	if not listeners then return end

	for _, listener in ipairs(listeners) do
		local fn = listener.fn
		if listener.once then
			self:remove(event, fn)
		end

		if listener.sync then
			fn(...)
		else
			coroutine.wrap(fn)(...)
		end
	end
end

function emitter:waitFor(event, timeout, predicate)
	local thread = coroutine.running()
	local uv_timer
	
	local fn = self:once(name, function(...)
		if predicate and not predicate(...) then return end
		if uv_timer then
			timer.clearTimeout(uv_timer)
		end
		return assert(coroutine.resume(thread, true, ...))
	end, true)

	uv_timer = timeout and timer.setTimeout(timeout, function()
		self:remove(name, fn)
		return assert(coroutine.resume(thread, false))
	end)

	return coroutine.yield()
end

return emitter
