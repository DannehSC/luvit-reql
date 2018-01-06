local emitter = require('./emitter.lua')
local colorize = require('pretty-print').colorize
local fmt, date = string.format, os.date

local datetime = '%F %T'

local logger = { }

function logger.err(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	emitter:fire('error')
end

function logger.hErr(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	process:exit(1)
end

function logger.warn(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt(colorize('number','[WARN]    ') .. '| %s', sig))
	emitter:fire('warn', sig)
end

function logger.info(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt(colorize('userdata','[INFO]    ') .. '| %s', sig))
	emitter:fire('info', sig)
end

function logger.debug(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt(colorize('userdata','[DEBUG]   ') .. '| %s', sig))
	emitter:fire('debug', sig)
end

return logger
