
local ReqlError = { }

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

function calculateHierarchy(str)
    local previous = hierarchy[str]

    if type(previous) == 'string' then
        previous = calculateHierarchy(previous)
    else
        return { str }
    end

    previous[#previous + 1] = str

    hierarchy[str] = previous
    return previous
end

for k in pairs(hierarchy) do calculateHierarchy(k) end
for k, v in pairs(hierarchy) do hierarchy[k] = table.concat(v, '/') end

local format = string.format

local metatable = { __tostring = function(self) return self.message end }
function ReqlError:__index(index)
    local path = hierarchy[index]

    return function(message, term, frames)
        if term then
            frames = type(frames) == 'table' and frames or { }
            
            message = ('%s | %s in:\n\t%s\n\t%s\n'):format(path, message, term, table.concat(frames, ',\n\t'))
        else
            message = ('%s | %s'):format(path, message)
        end
            
		return setmetatable({
            name = index,
            path = path,

			message = message,
			term    = term,
            frames  = frames
        }, metatable)
	end
end

return setmetatable({ }, ReqlError)
