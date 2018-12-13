
local connect = require('connect')
local reql = require('Utils/reql.lua')
local emitter = require('Utils/emitter.lua')
local cmanager = require('Utils/coroutinemanager.lua')
local logger_f = require('Utils/logger.lua')

-- Default options table || Do NOT edit, pass your options to the function instead

local default = {
	address = 'http://127.0.0.1',
	port = 28015,
	user = 'admin',
	password = '',
	db = 'test',
	reconnect = false,
	reusable = false,
	debug = false,
	file = 'luvitreql.log'
}

local format = string.format
local sub, len, find = string.sub, string.len, string.find

return {
	connect = function(options, callback)
		local logger = logger_f()

		options = options and options or {}
		local type = type(options)
		if type == 'function' then
			callback = options
			options, type = { }, 'table'
		end
		if type ~= 'table' then
			return logger:harderr(format('bad argument #1 to \'connect\' (table expected, got %s)', type))
		end
		for k, v in pairs(default) do
			if options[k] == nil then
				options[k] = v
			end
        end
        
		logger.options = options
        logger:setFile(options.file)
        
		if options.address:sub(#options.address) == '/' then
			options.address = options.address:sub(1, #options.address - 1)
		end
		if not find(options.address, 'https?', 1) == 1 then
			logger:warn('Procotol not supplied, defaulting to http://')
			options.address = format('http://%s', options.address)
        end
        
		return connect(options, callback, logger)
	end,

	reql = function()
		return reql()
	end,
	
	emitter = emitter,
	
	logger = logger_f(),
	
	_cmanager = cmanager
}
