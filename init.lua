local connect = require('connect')
local reql = require('Utils/reql.lua')
local logger = require('Utils/logger.lua')
local emitter = require('Utils/emitty.lua')

-- Default options table || Do NOT edit, pass your options to the function instead

local default = {
	address = 'http://127.0.0.1',
	port = 28015,
	user = 'admin',
	password = '',
	db = 'test',
	reconnect = false,
	reusable = false,
}

local format = string.format
local find = string.find

return {
	connect = function(options)
		options = options or {}
		local type = type(options)
		if type ~= 'table' then
			return error(format('Bad argument #1 to luvit-reql.connect(), table expected, got %s', type))
		end

		for k,v in pairs(default) do
			if options[k] == nil then
				options[k] = v
			end
		end

		if options.address:sub(#options.address)=='/'then
			options.address = options.address:sub(1,#options.address-1)
		end
		if not find(options.address, 'https?', 1) == 1 then
			logger.warn('Procotol not supplied, defaulting to http://')
			options.address = format('http://%s', options.address)
		end

		return connect(options)
	end,

	reql = function()
		return reql()
	end,

	emitter = emitter,

	logger = logger
}
