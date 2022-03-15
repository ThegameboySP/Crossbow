local RemoteEventMock = {}
RemoteEventMock.__index = RemoteEventMock

function RemoteEventMock.new()
	local serverEvent = Instance.new("BindableEvent")
	local clientEvent = Instance.new("BindableEvent")

	return setmetatable({
		OnServerEvent = serverEvent.Event;
		OnClientEvent = clientEvent.Event;
		
		_connectedClients = {};
		_serverRemoteEvent = nil;
		_localClient = nil;

		_serverEvent = serverEvent;
		_clientEvent = clientEvent;
	}, RemoteEventMock)
end

function RemoteEventMock:FireClient(client, ...)
	local remoteEvent = self._connectedClients[client]
	if remoteEvent then
		remoteEvent._clientEvent:Fire(...)
	end
end

function RemoteEventMock:FireAllClients(...)
	for _, remoteEvent in pairs(self._connectedClients) do
		remoteEvent._clientEvent:Fire(...)
	end
end

function RemoteEventMock:FireServer(...)
	self._serverRemoteEvent._serverEvent:Fire(self._localClient, ...)
end

function RemoteEventMock:connectClient(remoteEvent, client)
	self._connectedClients[client] = remoteEvent
	remoteEvent:_connectServer(self, client)
	
	return function()
		self._connectedClients[client] = nil
	end
end

function RemoteEventMock:_connectServer(remoteEvent, client)
	self._serverRemoteEvent = remoteEvent
	self._localClient = client
end

return RemoteEventMock