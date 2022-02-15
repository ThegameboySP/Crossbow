local Observers = {}
Observers.__index = Observers

local Connection = {}
Connection.__index = Connection

local function newConnection(hook, name, handler, first)
	return setmetatable({
		_hook = hook;
		_name = name;
		_handler = handler;
		_next = first;
	}, Connection)
end

function Connection:Disconnect()
	if self._hook == false then
		-- Connection has already been disconnected.
		return
	end

	local head = self._hook[self._name]
	if head == self then
		self._hook[self._name] = self._next
	else
		local prev = head
		while prev and prev._next ~= self do
			prev = prev._next
		end

		if prev then
			prev._next = self._next
		end
	end

	self._hook = false
end
Connection.Destroy = Connection.Disconnect
Connection.__call = Connection.Disconnect

function Observers.new()
	return setmetatable({}, Observers)
end

function Observers.wrap(tbl)
	return setmetatable(tbl, Observers)
end

function Observers:On(name, handler)
	local first = rawget(self, name)
	if first then
		local connection = newConnection(self, name, handler, first)
		self[name] = connection

		return connection
	end

	local connection = newConnection(self, name, handler)
	self[name] = connection
	return connection
end

function Observers:OnAlways(name, handler)
	self[name] = {_handler = handler, _next = rawget(self, name)}
end

function Observers:Fire(name, ...)
	local hook = rawget(self, name)
	while hook do
		xpcall(hook._handler, function(msg)
			task.spawn(error, debug.traceback(msg, 2))
		end, ...)
		hook = hook._next
	end
end

function Observers:DisconnectFor(name)
	self[name] = nil
end

function Observers:DisconnectAll()
	table.clear(self)
end
Observers.Destroy = Observers.DisconnectAll

function Observers:WaitFor(name)
	local co = coroutine.running()
	local con
	con = self:On(name, function(...)
		con:Disconnect()
		task.spawn(co, ...)
	end)
	
	return coroutine.yield()
end

return Observers