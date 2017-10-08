local manager={}
function manager.isCoro()
	local thread,bool=coroutine.running()
	return not bool
end
return manager