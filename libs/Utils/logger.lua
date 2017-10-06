local fmt=string.format
local logger={
	err={},
	warn={},
	info={},
	other={},
}
function logger.err.format(sig,err)
	sig=sig or'?'err=err or'no err?'
	print(fmt("[ERROR] %s || %s",sig,err))
end
function logger.warn.format(sig,dat)
	sig=sig or'?'dat=dat or'no warning?'
	print(fmt("[WARNING] %s || %s",sig,dat))
end
function logger.info.format(sig,dat)
	sig=sig or'?'dat=dat or'no warning?'
	print(fmt("[INFO] %s || %s",sig,dat))
end
return logger