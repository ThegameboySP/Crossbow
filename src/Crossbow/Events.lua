local Events = {}
Events.__index = Events

function Events.new()
	return setmetatable({
		_order = {};
		_events = {};
	}, Events)
end

function Events:clear()
	table.clear(self._order)
	table.clear(self._events)
end

function Events:isEmpty()
	return next(self._events) == nil
end

function Events:contains(name)
	return self._events[name] ~= nil
end

function Events:getAll()
	return {unpack(self._order)}
end

function Events:get(name)
	local eventsEntry = self._events[name]
	if eventsEntry == nil then
		return {}
	end

	local events = {}
	for _, event in ipairs(eventsEntry) do
		table.insert(events, event.args)
	end

	return events
end

function Events:iterateAll()
	local i = 0

	return function()
		i += 1

		local event = self._order[i]
		if event == nil then
			return nil
		end

		return event.name, event.args
	end
end

function Events:iterate(name)
	local events = self._events[name]
	if events == nil then
		return function() end
	end
	
	local len = #events
	local i = 1

	return function()
		if i > len then
			return nil
		end

		local args = events[i].args
		i += 1
		return i, unpack(args, 1, args.n)
	end
end

function Events:fire(name, ...)
	local events = self._events[name]
	if events == nil then
		events = {}
		self._events[name] = events
	end
	
	local event = table.freeze({
		name = name;
		args = table.pack( ... );
	})

	table.insert(events, event)
	table.insert(self._order, event)
end

return Events