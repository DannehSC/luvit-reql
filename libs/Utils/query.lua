local query={}
function query:table(t)
	self.table=t
end
function query:add(t)
	table.insert(self.add,t)
end
local function copy(t)
	local nt={}
	for i,v in pairs(t)do
		nt[i]=v
	end
	return nt
end
return function()
	return copy(query)
end