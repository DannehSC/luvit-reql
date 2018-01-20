
local emitter = require('./emitter.lua')
local fmt, date = string.format, os.date

local datetime = '%F %T'

local logger = { }

function logger.err(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt('\27[1;31m[ERROR]\27[0m   | %s', sig))
	emitter:fire('error')
end

function logger.harderr(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt('\27[1;31m[ERROR]\27[0m   | %s', sig))
	process:exit(1)
end

function logger.warn(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt('\27[1;33m[WARNING]\27[0m | %s', sig))
	emitter:fire('warn', sig)
end

function logger.info(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt('\27[1;32m[INFO]\27[0m    | %s', sig))
	emitter:fire('info', sig)
end

function logger.debug(sig)
	sig = sig or '?'
	print(date(datetime) .. ' | ' .. fmt('\27[1;36m[DEBUG]\27[0m   | %s', sig))
	emitter:fire('debug', sig)
end

return logger
