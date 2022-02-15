local Events = {}
Events.__index = Events

function Events.new()
	return setmetatable({}, Events)
end

function Events:iterate(name)
	local events = self[name]
	if events == nil then
		return function() end
	end
	
	local len = #events
	local i = 1

	return function()
		if i > len then
			return nil
		end

		local args = events[i]
		i += 1
		return unpack(args, 1, args.n)
	end
end

function Events:fire(name, ...)
	local events = self[name]
	if events == nil then
		events = {}
		self[name] = events
	end
	
	table.insert(events, table.pack( ... ))
end

return Events