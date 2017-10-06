local connect = require('connect')
local reql = require('Utils/reql.lua')

-- Default options table || Do NOT edit, pass your options to the function instead

local default = {
    address = 'http://127.0.0.1',
    port = 28015,
    user = 'admin',
    password = '',
    db = 'test'
}

local format = string.format
local sub, len, find = string.sub, string.len, string.find

return {
	connect = function(options)
        options = options and options or {}
        local type = type(options)
        if not type == 'table' then
            error(format('Bad argument #1 to luvit-reql/init.lua, table expected, got %s', type))
        end
		for k,v in pairs(default) do
			if not options[k] then
				options[k] = v
			end
		end
		if not sub(options.address, len(options.address)) == '/' then
			options.address = options.address..'/'
		end
        if not find(options.address, 'https?', 1) == 1 then
            print('[WARNING] Procotol not supplied, defaulting to http://')
			options.address = format('http://%s', options.address)
		end
		return connect(options)
	end,

	reql = reql()
}