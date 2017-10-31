local ReqlError = {}

local hierarchy = {
	ReqlCompileError = 'ReqlError',
	ReqlDriverError = 'ReqlError',
	ReqlAuthError = 'ReqlDriverError',
	ReqlRuntimeError = 'ReqlError',
	ReqlResourceLimitError = 'ReqlRuntimeError',
	ReqlUserError = 'ReqlRuntimeError',
	ReqlInternalError = 'ReqlRuntimeError',
	ReqlTimeoutError = 'ReqlRuntimeError',
	ReqlPermissionsError = 'ReqlRuntimeError',
	ReqlQueryLogicError = 'ReqlRuntimeError',
	ReqlNonExistenceError = 'ReqlQueryLogicError',
	ReqlAvailabilityError = 'ReqlRuntimeError',
	ReqlOpFailedError = 'ReqlAvailabilityError',
	ReqlOpIndeterminateError = 'ReqlAvailabilityError'
}

local format = string.format

local errMeta = {
	__tostring = function(t)
		return t:init()
	end
}

function ReqlError.__index(_, index)
	return function(msg, term, frames)
		local err = setmetatable({
			name = index,
			message = msg,
			term = term,
			frames = frames
		}, errMeta)
		function err:init()
			local h = ''
			local last = self.name
			while last do
				if hierarchy[last] then
					h = format('%s/%s', hierarchy[last], h)
					last = hierarchy[last]
				else
					last = nil
				end
			end
			local message = format('%s%s || %s', h, self.name, self.message)
			if self.term then
				self.frames = type(self.frames) == 'table' and self.frames or {}
				message = format('%s in:\n\t%s\n\t%s\n', message, self.term, table.concat(frames, ',\n\t'))
			end
			return message
		end
		return err
	end
end

ReqlError = setmetatable({}, ReqlError)

return ReqlError
