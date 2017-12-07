local emitter = require('./emitty.lua')
local colorize = require('pretty-print').colorize
local fmt, date = string.format, os.date

local pat = '%F %T'

local loggerMeta = function(self,...)
	if self['format'] then
		return self['format'](...)
	end
end

local logger = {
	err = setmetatable({}, { __call = loggerMeta }),
	warn = setmetatable({}, { __call = loggerMeta }),
	info = setmetatable({}, { __call = loggerMeta }),
	hErr = setmetatable({}, { __call = loggerMeta }),
	other = setmetatable({}, { __call = loggerMeta }),
	debug = setmetatable({}, { __call = loggerMeta }),
}

function logger.err.format(sig, err)
	sig = sig or '?'
	print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	if err then
		print(('logger.err.format: 2nd value deprecated.\nData: '..err))
	end
	emitter:fire('error', err)
end

function logger.hErr.format(sig, err)
	sig = sig or '?'
	print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	if err then
		print(('logger.hErr.format: 2nd value deprecated.\nData: '..err))
	end
	error 'See the red print above this.'
end

function logger.warn.format(sig, dat)
	sig = sig or '?'
	print(date(pat) .. ' | ' .. fmt(colorize('number','[WARN]    ') .. '| %s', sig))
	if dat then
		print(('logger.warn.format: 2nd value deprecated.\nData: '..dat))
	end
	emitter:fire('warn', sig, dat)
end

function logger.info.format(sig, dat)
	sig = sig or '?'
	print(date(pat) .. ' | ' .. fmt(colorize('userdata','[INFO]    ') .. '| %s', sig))
	if dat then
		print(('logger.info.format: 2nd value deprecated.\nData: '..dat))
	end
	emitter:fire('info', sig, dat)
end

function logger.debug.format(sig)
	sig = sig or '?'
	print(date(pat) .. ' | ' .. fmt(colorize('userdata','[DEBUG]   ') .. '| %s', sig))
	emitter:fire('debug', sig)
end

return logger
