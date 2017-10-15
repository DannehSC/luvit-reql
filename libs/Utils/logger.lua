local colorize=require('pretty-print').colorize
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
		print(colorize('err',fmt("[ERROR] %s",sig)))
	else
		print(colorize('err',fmt("[ERROR] %s || %s",sig,err)))
	end
end
function logger.warn.format(sig,dat)
	sig=sig or'?'
	if not dat then
		print(fmt(colorize('number','[WARN]')..' %s',dat))
	else
		print(fmt(colorize('number','[WARN]')..' %s || %s',sig,dat))
	end
end
function logger.info.format(sig,dat)
	sig=sig or'?'
	if not dat then
		print(fmt(colorize('userdata','[INFO]')..' %s',sig))
	else
		print(fmt(colorize('userdata','[INFO]')..' %s || %s',sig,dat))
	end
end
return logger