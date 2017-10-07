local fmt=string.format
local logger={
	err={},
	warn={},
	info={},
	other={},
}
function logger.err.format(sig,err)
	sig=sig or'?'
	if not err then
		print(fmt("[ERROR] %s",sig))
	else
		print(fmt("[ERROR] %s || %s",sig,err))
	end
end
function logger.warn.format(sig,dat)
	sig=sig or'?'
	if not dat then
		print(fmt("[WARN] %s",dat))
	else
		print(fmt("[WARN] %s || %s",sig,dat))
	end
end
function logger.info.format(sig,dat)
	sig=sig or'?'
	if not dat then
		print(fmt("[INFO] %s",sig))
	else
		print(fmt("[INFO] %s || %s",sig,dat))
	end
end
return logger