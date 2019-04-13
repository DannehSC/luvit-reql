
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
    if logger._file then
        return writeSync(logger._file, -1, f('%s | %s | %s\n', date(datetime), typeOf, data))
    end
end

return function()
	local logger = { }

    function logger:setFile(name)
        if self._file then closeSync(self._file) end

        self._file = openSync(name)
        self:debug('Set file to: ' .. tostring(name))
	end

	function logger:info(fmt, ...)
        fmt = tostring(fmt):format(...)

		write(self, types[1], fmt)
        print(date(datetime) .. ' | ' .. f('\27[1;32m%s\27[0m | %s', types[1], fmt))
        emitter:fire('info', fmt)
	end

	function logger:warn(fmt, ...)
        fmt = tostring(fmt):format(...)

		write(self, types[2], fmt)
        print(date(datetime) .. ' | ' .. f('\27[1;33m%s\27[0m | %s', types[2], fmt))
        emitter:fire('warn', fmt)
	end

	function logger:err(fmt, ...)
        fmt = tostring(fmt):format(...)

        write(self, types[3], fmt)
        print(date(datetime) .. ' | ' .. f('\27[1;31m%s\27[0m | %s', types[3], fmt))
        emitter:fire('error', fmt)
	end

	function logger:debug(fmt, ...)
        if self.options and not self.options.debug then return end

        fmt = tostring(fmt):format(...)

        write(self, types[4], fmt)
        print(date(datetime) .. ' | ' .. f('\27[1;36m%s\27[0m | %s', types[4], fmt))
        emitter:fire('debug', fmt)
	end

	function logger:harderr(fmt, ...)
        fmt = tostring(fmt):format(...)
        local trace = debug.traceback('', 2):gsub('stack traceback:\n(.+)', '%1')

        write(self, types[5], fmt .. tb)
        print(date(datetime) .. ' | ' .. f('\27[1;31m%s\27[0m | %s %s', types[5], fmt, trace))
        emitter:fire('hard-error', fmt)
        return error(fmt)
	end

	function logger:assert(truthy, fmt, ...)
        if truthy then
            return truthy, fmt
        else
            fmt = tostring(fmt):format(...)
            local trace = debug.traceback('', 2):gsub('stack traceback:\n(.+)', '%1')

            write(self, types[5], fmt .. tb)
            print(date(datetime) .. ' | ' .. f('\27[1;31m%s\27[0m | %s %s', types[5], fmt, trace))
            emitter:fire('hard-error', fmt)
            return error(fmt)
        end
	end

	return logger
end
