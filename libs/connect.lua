local json=require('json')
local ssl=require('openssl')
local net=require('coro-net')
local errors=require('./error.lua')
local x=require('./Utils/bits.lua')
local reql=require('./Utils/reql.lua')
local pbkdf=require('./Utils/pbkdf.lua')
local logger=require('./Utils/logger.lua')
local compare_digest=require('./Utils/compare.lua')
local cmanager=require('./Utils/coroutinemanager.lua')
local process=require('./Utils/processor.lua').processData

local xor, bxor256 = x[1], x[2] -- NOTE: unused variable

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
local function copy(t)
	local n = {}
	for k, v in pairs(t)do
		n[k] = v
	end
	return n
end
local connect
function connect(options)
	local socket = {
		closed = false
	}
	local addr = options.address
	addr = addr:gsub('https://','')
	addr = addr:gsub('http://','')
	local tls = options.address:sub(1, 5) == 'https' -- NOTE: unused variable
	local function connectToRethinkdb()
		local opt = copy(options)
		local stuff = {net.connect({
			host = addr,
			port = options.port,
		})}
		logger.info.format(format('Connecting to %s:%s', addr, options.port))
		local read, write, close = stuff[1], stuff[2], stuff[6]
		if type(write) == "string"then
			socket.closed = true
			return logger.err.format("Socket", write)
		end
		socket.read = read
		socket.write = write
		socket.close = function()
			socket.closed = true
			close()
		end
		local user, auth_key = options.user, options.password
		-- Initiation (First Client Message/First Server Challenge)
		write(string.pack('<I', 0x34c2bdc3))
		local success, res = pcall(function() return json.decode(read()) end) -- NOTE: unused variable
		if not success then
			socket.close()
			return logger.err.format(errors.ReqlDriverError('Error reading JSON data.'))
		end
		local nonce = ssl.base64(ssl.random(18), true)
		local client_first_message = 'n=' .. user .. ',r=' .. nonce
		-- Second Client Message
		write(json.encode {
			protocol_version = 0,
			authentication_method = "SCRAM-SHA-256",
			authentication = 'n,,'.. client_first_message
		}..'\0')
		-- Second Server Challenge
		res = json.decode(read())
		if not res.success then
			socket.close()
			return logger.err.format(errors.ReqlAuthError("Error: "..res.error))
		end
		local auth = {}
		local server_first_message = res.authentication
		for k, v in gmatch(server_first_message .. ',', '([rsi])=(.-),') do
			auth[k] = v
		end
		local i, j = auth.r:find(nonce,1,true)
		assert(i == 1 and j == #nonce,errors.ReqlDriverError('Invalid Nonce'))
		auth.i = tonumber(auth.i)
		local client_final_message = 'c=biws,r=' .. auth.r
		local salt = ssl.base64(auth.s, false)
		local salted_password, salt_error = pbkdf('sha256', auth_key, salt, auth.i, 32) -- NOTE: unused variable
		if not salted_password then
			socket.close()
			return logger.err.format(errors.ReqlDriverError("Salt error"))
		end
		local ckHMAC = ssl.hmac.new('sha256',salted_password)
		local client_key = ckHMAC:final('Client Key', true)
		local stored_key = ssl.digest.digest('sha256', client_key, true)
		local auth_message = concat({client_first_message,server_first_message,client_final_message},',')
		local csHMAC = ssl.hmac.new('sha256', stored_key)
		local client_signature = csHMAC:final(auth_message, true)
		local client_proof = bxor256(client_key, client_signature)
		-- Third Client Message
		write(json.encode {
			authentication = concat{client_final_message,',p=', ssl.base64(client_proof,true)}
		}..'\0')
		-- Third Server Challenge
		res = json.decode(read())
		if not res.success then
			socket.close()
			if options.debug then
				p('DEBUG',res.error)
			end
			return logger.err.format(errors.ReqlAuthError("Error: "..res.error))
		end
		for k,v in gmatch(res.authentication..',','([vV])=(.-),')do
			auth[k] = v
		end
		if not auth.v then
			return logger.err.format(errors.ReqlDriverError("Missing server signature"))
		end
		local skHMAC = ssl.hmac.new('sha256', salted_password)
		local server_key = skHMAC:final('Server Key', true)
		local ssHMAC = ssl.hmac.new('sha256', server_key)
		local server_signature = ssHMAC:final(auth_message, true)
		if not compare_digest(auth.v, server_signature)then
			socket.close()
			return logger.err.format(errors.ReqlAuthError("Invalid server signature"))
		end
		logger.info.format(format("Connection to %s:%s complete.",addr,options.port))
		coroutine.wrap(function()
			for data in read do
				p(data)
				process(data)
			end
			socket.closed=true
			logger.warn.format(format('Connection to %s:%s closed.',addr,options.port))
			if options.reconnect then
				connect(opt)
			end
		end)()
	end
	if checkCoroutine()then
		connectToRethinkdb()
	else
		coroutine.wrap(connectToRethinkdb)()
	end
	options.password = '<HIDDEN>'
	local conn = setmetatable({
		_socket = socket,
		_getToken = new_token(),
		_options = options,
		close = function()
			logger.info.format('Closing socket, cleaning up.')
			options.reconnect = false
			socket.close()
		end
	},{})
	conn.reql = function()
		return reql(conn)
	end
	return conn
end
return connect
