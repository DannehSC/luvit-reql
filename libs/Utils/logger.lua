local emitter = require('./emitty.lua')
local colorize = require('pretty-print').colorize
local fmt, date = string.format, os.date

local pat = '%F %T'

local metaCall=function(self,...)
	if self['format']then
		return self['format'](...)
	end
end

local logger = {
	err = setmetatable({},{__call=metaCall}),
	warn = setmetatable({},{__call=metaCall}),
	info = setmetatable({},{__call=metaCall}),
	hErr = setmetatable({},{__call=metaCall}),
	other = setmetatable({},{__call=metaCall}),
}

function logger.err.format(sig,err)
	sig = sig or '?'
	if not err then
		print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	else
		print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s || %s", sig, err)))
	end
	emitter:fire('error',err)
end

function logger.hErr.format(sig,err)
	sig = sig or '?'
	if not err then
		print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	else
		print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s || %s", sig, err)))
	end
	error'See the red print above this.'
end

function logger.warn.format(sig,dat)
	sig = sig or '?'
	if not dat then
		print(date(pat) .. ' | ' .. fmt(colorize('number','[WARN]    ') .. '| %s', sig))
	else
		print(date(pat) .. ' | ' .. fmt(colorize('number','[WARN]    ') .. '| %s || %s', sig, dat))
	end
	emitter:fire('warn',sig,dat)
end

function logger.info.format(sig,dat)
	sig = sig or '?'
	if not dat then
		print(date(pat) .. ' | ' .. fmt(colorize('userdata','[INFO]    ') .. '| %s', sig))
	else
		print(date(pat) .. ' | ' .. fmt(colorize('userdata','[INFO]    ') .. '| %s || %s', sig, dat))
	end
	emitter:fire('info',sig,dat)
end

return logger
