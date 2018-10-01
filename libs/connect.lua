
local json = require('json')
local ssl = require('openssl')
local net = require('coro-net')
local errors = require('./error.lua')
local bits = require('./Utils/bits.lua')
local reql = require('./Utils/reql.lua')
local pbkdf = require('./Utils/pbkdf.lua')
local emitter = require('./Utils/emitter.lua')
local compare_digest = require('./Utils/compare.lua')
local cmanager = require('./Utils/coroutinemanager.lua')

local dump = require('pretty-print').dump

local process = require('./Utils/processor.lua').processData

local bxor256 = bits.bxor256

local concat, gmatch, format = table.concat, string.gmatch, string.format
local checkCoroutine = cmanager.isCoro

local function new_token()
	local var = 0
	local function get_token()
		var = var + 1
		return var
	end
	return get_token
end

local function decoder()
	local len
	local data_buffer = { }
	local total_len = 0

	local accept
	function accept(buffer, chunks)
		chunks = chunks or { }

		local other = buffer:find('%]}............{"t":%d%d?,"', 26)
		if other then
			accept(buffer:sub(other + 2), chunks)
			buffer = buffer:sub(1, other + 1)
		end

		local head = buffer:match('^(............){"t":%d%d?,"')

		if head then
			len = string.unpack('<I4', head:sub(-4)) + 12
			data_buffer = { }
		end

		if len then
			if #buffer == len then
				chunks[#chunks + 1] = buffer
			else
				data_buffer[#data_buffer + 1] = buffer
				total_len = total_len + #buffer

				if total_len == len then
					total_len = 0
					data_buffer = { }
					chunks[#chunks + 1] = table.concat(data_buffer)
				end
			end
		else
			chunks[#chunks + 1] = buffer
		end

		if #chunks > 0 then
			return chunks
		end
	end

	return function(buffer)
		return accept(buffer)
	end
end

local connect
function connect(options, callback, logger)
	local socket = {
		closed = false
	}
	local addr = options.address
	addr = addr:gsub('https?://', '')

	local function connectToRethinkdb(conn)
		local stuff = { net.connect({
			host = addr,
			port = options.port,
			decode = decoder()
		}) }

		logger:info(format('Connecting to %s:%s', addr, options.port))
		local read, write, close = stuff[1], stuff[2], stuff[6]
		if type(write) == 'string' then
			socket.closed = true
			return logger:err('Socket error | ' .. write)
		end
		socket.read = read
		socket.write = write
		socket.close = function()
			socket.closed = true
			close()
			emitter:fire('close')
		end
		local user, auth_key = options.user, options.password

		-- Initiation (First Client Message/First Server Challenge)
		write(string.pack('<I', 0x34c2bdc3))

		local success = pcall(json.decode, read()[1])
		if not success then
			socket.close()
			return logger:err(errors.ReqlDriverError('Error reading JSON data.'))
		end
		local nonce = ssl.base64(ssl.random(18), true)
		local client_first_message = 'n=' .. user .. ',r=' .. nonce

		-- Second Client Message
		write(json.encode({
			protocol_version = 0,
			authentication_method = 'SCRAM-SHA-256',
			authentication = 'n,,' .. client_first_message
		}) .. '\0')

		-- Second Server Challenge
		res = json.decode(read()[1])
		if not res.success then
			socket.close()
			return logger:err(errors.ReqlAuthError('Error: ' .. res.error))
		end
		local auth = {}
		local server_first_message = res.authentication
		for k, v in gmatch(server_first_message .. ',', '([rsi])=(.-),') do
			auth[k] = v
		end
		local i, j = auth.r:find(nonce, 1, true)
		logger:assert(i == 1 and j == #nonce, errors.ReqlDriverError('Invalid Nonce'))
		auth.i = tonumber(auth.i)
		local client_final_message = 'c=biws,r=' .. auth.r
		local salt = ssl.base64(auth.s, false)
		local salted_password, salt_error = pbkdf('sha256', auth_key, salt, auth.i, 32) -- NOTE: "salt_error" unused variable
		if not salted_password then
			socket.close()
			return logger:err(errors.ReqlDriverError('Salt error'))
		end
		local ckHMAC = ssl.hmac.new('sha256', salted_password)
		local client_key = ckHMAC:final('Client Key', true)
		local stored_key = ssl.digest.digest('sha256', client_key, true)
		local auth_message = concat({ client_first_message, server_first_message, client_final_message }, ',')
		local csHMAC = ssl.hmac.new('sha256', stored_key)
		local client_signature = csHMAC:final(auth_message, true)
		local client_proof = bxor256(client_key, client_signature)

		-- Third Client Message
		write(json.encode({
			authentication = concat({ client_final_message, ',p=', ssl.base64(client_proof, true) })
		}) .. '\0')

		-- Third Server Challenge
		res = json.decode(read()[1])
		if not res.success then
			socket.close()
			logger:debug(dump(res))
			return logger:err(errors.ReqlAuthError('Error: ' .. res.error))
		end
		for k,v in gmatch(res.authentication .. ',', '([vV])=(.-),')do
			auth[k] = v
		end
		if not auth.v then
			return logger:err(errors.ReqlDriverError('Missing server signature'))
		end
		local skHMAC = ssl.hmac.new('sha256', salted_password)
		local server_key = skHMAC:final('Server Key', true)
		local ssHMAC = ssl.hmac.new('sha256', server_key)
		local server_signature = ssHMAC:final(auth_message, true)
		if not compare_digest(auth.v, server_signature) then
			socket.close()
			return logger:err(errors.ReqlAuthError('Invalid server signature'))
		end

		logger:info(format('Connection to %s:%s complete.', addr, options.port))
		socket.closed = false
		emitter:fire('connected', conn)
		coroutine.wrap(function()
			for data in read do
				for _, chunk in next, data do
					process(chunk)
				end
			end
			socket.closed = true
			logger:warn(format('Connection to %s:%s closed.', addr, options.port))
			if options.reconnect then
				connect(options, callback, logger)
			end
		end)()
	end

	local conn = {
		_socket = socket,
		_getToken = new_token(),
		_options = options,
		logger = logger,
		close = function()
			logger:info('Closing socket, cleaning up.')
			options.reconnect = false
			socket.close()
		end,
		connected = function()
			return not socket.closed
		end
	}

	conn.reql = function()
		return reql(conn)
	end
	
	conn.test = function()
		if checkCoroutine() then
			require('./utils/test.lua')(conn)
        else
            print('asynchronous testing is not supported.')
		end
	end

	if checkCoroutine() then
		logger:debug('Running Luvit-ReQL in Sync Mode')
		connectToRethinkdb(conn)
		
		if callback then
			coroutine.wrap(callback)(conn)
		end

		return conn
	else
		logger:warn('Running Luvit-ReQL in Async Mode')
		coroutine.wrap(function()
			connectToRethinkdb(conn)

			if type(callback) == 'function' then
				callback(conn)
			else
				logger:harderr('Cannot run Luvit-ReQL in Async Mode without a callback')
			end
		end)()
	end
end

return connect
