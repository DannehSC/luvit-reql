
local fs = require('fs')
local emitter = require('./emitter.lua')

local fmt, date = string.format, os.date
local openSync, writeSync, closeSync = fs.openSync, fs.writeSync, fs.closeSync
local datetime = '%F %T'

local logger = { }
local types = {
	[1] = '[INFO]   ',
	[2] = '[WARNING]',
	[3] = '[ERROR]  ',
	[4] = '[DEBUG]  ',
	[5] = '[H ERROR]',
}

function write(typeOf, data)
	if logger._file ~= false then
		local file
		if logger._opened == nil then
			file = openSync(logger._file, 'a')
		else
			file = logger._opened
		end
		writeSync(file, -1, fmt('%s | %s | %s\n', date(datetime), typeOf, data))
	end
end

function logger.setFile(fileName)
	if logger._opened then
		closeSync(logger._opened)
	end
	logger._file = fileName
	logger.info('Set file to: '..fileName)
end

function logger.err(sig)
	sig = sig or '?'
	write(types[3], sig)
	print(date(datetime) .. ' | ' .. fmt('\27[1;31m%s\27[0m | %s', types[3], sig))
	emitter:fire('error')
end

function logger.harderr(sig)
	sig = sig or '?'
	write(types[5], sig)
	print(date(datetime) .. ' | ' .. fmt('\27[1;31m%s\27[0m | %s', types[5], sig))
	process:exit(1)
end

function logger.warn(sig)
	sig = sig or '?'
	write(types[2], sig)
	print(date(datetime) .. ' | ' .. fmt('\27[1;33m%s\27[0m | %s', types[2], sig))
	emitter:fire('warn', sig)
end

function logger.info(sig)
	sig = sig or '?'
	write(types[1], sig)
	print(date(datetime) .. ' | ' .. fmt('\27[1;32m%s\27[0m | %s', types[1], sig))
	emitter:fire('info', sig)
end

function logger.debug(sig)
	sig = sig or '?'
	write(types[4], sig)
	print(date(datetime) .. ' | ' .. fmt('\27[1;36m%s\27[0m | %s', types[4], sig))
	emitter:fire('debug', sig)
end

return logger
