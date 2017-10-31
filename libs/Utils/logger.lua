local colorize = require('pretty-print').colorize
local fmt, date = string.format, os.date

local pat = '%F %T'

local logger = {
	err = {},
	warn = {},
	info = {},
	other = {},
}

function logger.err.format(sig,err)
	sig = sig or '?'
	if not err then
		print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s", sig)))
	else
		print(date(pat) .. ' | ' .. colorize('err', fmt("[FAIL]    | %s || %s", sig, err)))
	end
end

function logger.warn.format(sig,dat)
	sig = sig or '?'
	if not dat then
		print(date(pat) .. ' | ' .. fmt(colorize('number','[WARN]    ') .. '| %s', sig))
	else
		print(date(pat) .. ' | ' .. fmt(colorize('number','[WARN]    ') .. '| %s || %s', sig, dat))
	end
end

function logger.info.format(sig,dat)
	sig = sig or '?'
	if not dat then
		print(date(pat) .. ' | ' .. fmt(colorize('userdata','[INFO]    ') .. '| %s', sig))
	else
		print(date(pat) .. ' | ' .. fmt(colorize('userdata','[INFO]    ') .. '| %s || %s', sig, dat))
	end
end

return logger
