
local fs = require('fs')
local emitter = require('./emitter.lua')

local f, date = string.format, os.date
local openSync, writeSync, closeSync = fs.openSync, fs.writeSync, fs.closeSync
local datetime = '%F %T'

local types = {
	[1] = '[INFO]   ',
	[2] = '[WARNING]',
	[3] = '[ERROR]  ',
	[4] = '[DEBUG]  ',
	[5] = '[HARDERR]',
}

local function write(logger, typeOf, data)
	if type(logger._file) == 'string' then
		local file
		if logger._opened == nil then
			file = openSync(logger._file, 'a')
			logger._opened = file
		else
			file = logger._opened
		end
		writeSync(file, -1, f('%s | %s | %s\n', date(datetime), typeOf, data))
	end
end

local function setFile(logger, fileName)
	if self ~= logger then sig = self end
	
	if logger._opened then
		closeSync(logger._opened)
	end
	logger._file = fileName
	logger:info('Set file to: '..tostring(fileName))
end

local function info(logger, fmt, ...)
	fmt = tostring(fmt)
	fmt = fmt:format(...)

	write(logger, types[1], fmt)
	print(date(datetime) .. ' | ' .. f('\27[1;32m%s\27[0m | %s', types[1], fmt))
	emitter:fire('info', fmt)
end

local function warn(logger, fmt, ...)
	fmt = tostring(fmt)
	fmt = fmt:format(...)

	write(logger, types[2], fmt)
	print(date(datetime) .. ' | ' .. f('\27[1;33m%s\27[0m | %s', types[2], fmt))
	emitter:fire('warn', fmt)
end

local function err(logger, fmt, ...)
	fmt = tostring(fmt)
	fmt = fmt:format(...)

	write(logger, types[3], fmt)
	print(date(datetime) .. ' | ' .. f('\27[1;31m%s\27[0m | %s', types[3], fmt))
	emitter:fire('error', fmt)
end

local debuglib = debug -- good function names
local function debug(logger, fmt, ...)
	if logger.options and not logger.options.debug then return end

	fmt = tostring(fmt)
	fmt = fmt:format(...)

	write(logger, types[4], fmt)
	print(date(datetime) .. ' | ' .. f('\27[1;36m%s\27[0m | %s', types[4], fmt))
	emitter:fire('debug', fmt)
end

local function harderr(logger, fmt, ...)
	fmt = tostring(fmt)
	fmt = fmt:format(...)
	local tb = debuglib.traceback('', 2):gsub('stack traceback:\n(.+)', '%1')

	write(logger, types[5], fmt .. tb)
	print(date(datetime) .. ' | ' .. f('\27[1;31m%s\27[0m | %s %s', types[5], fmt .. tb))
	emitter:fire('hard-error', fmt)
	return error(fmt)
end

return function()
	local logger = { }

	function logger:setFile(name)
		if self ~= logger then name = self end
		
		return setFile(logger, name)
	end

	function logger:info(fmt, ...)
		if self ~= logger then
			return info(logger, self, fmt, ...)
		else
			return info(logger, fmt, ...)
		end
	end

	function logger:warn(fmt, ...)
		if self ~= logger then
			return warn(logger, self, fmt, ...)
		else
			return warn(logger, fmt, ...)
		end
	end

	function logger:err(fmt, ...)
		if self ~= logger then
			return err(logger, self, fmt, ...)
		else
			return err(logger, fmt, ...)
		end
	end

	function logger:debug(fmt, ...)
		if self ~= logger then
			return debug(logger, self, fmt, ...)
		else
			return debug(logger, fmt, ...)
		end
	end

	function logger:harderr(fmt, ...)
		if self ~= logger then
			return harderr(logger, self, fmt, ...)
		else
			return harderr(logger, fmt, ...)
		end
	end

	function logger:assert(truthy, fmt, ...)
		if self ~= logger then
			if self then
				return self, truthy, fmt, ...
			else
				return harderr(logger, self, fmt, ...)
			end
		else
			if truthy then
				return truthy, fmt, ...
			else
				return harderr(logger, fmt, ...)
			end
		end
	end

	return logger
end
