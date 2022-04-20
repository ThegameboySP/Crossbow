local EventQueue = {}
EventQueue.__index = EventQueue

function EventQueue.new()
    return setmetatable({
        _connections = {};
        _queue = {};
        _events = {};
    }, EventQueue)
end

function EventQueue:connect(id, event)
    if self._events[id] ~= event then
        self._queue[id] = nil
        if self._connections[id] then
            self._connections[id]:Disconnect()
        end
    end

    local queue = self._queue[id]
    if queue == nil then
        queue = {}
        self._queue[id] = queue
    end

    self._events[id] = event
	self._connections[id] = event:Connect(function(...)
        table.insert(queue, table.pack(...))
	end)
end

function EventQueue:isConnected(id)
    return self._connections[id] ~= nil
end

function EventQueue:disconnect(id)
    if self._connections[id] then
        self._connections[id]:Disconnect()
        self._connections[id] = nil
        
        self._events[id] = nil
        self._queue[id] = nil
    end
end

function EventQueue:iterate(id)
    local queue = self._queue[id]
    local i = 0

    return function()
        i += 1
        local eventValues = table.remove(queue, 1)
        if eventValues == nil then
            return
        end
        
        return i, unpack(eventValues, 1, eventValues.n)
    end
end

return EventQueue