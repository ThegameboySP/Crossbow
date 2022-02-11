local RemoteEventMock = {}
RemoteEventMock.__index = RemoteEventMock

function RemoteEventMock.new()
	local serverEvent = Instance.new("BindableEvent")
	local clientEvent = Instance.new("BindableEvent")

	return setmetatable({
		_connectedClients = {};
		_serverRemoteEvent = nil;
		_localClient = nil;

		serverEvent = serverEvent;
		clientEvent = clientEvent;

		OnServerEvent = serverEvent.Event;
		OnClientEvent = clientEvent.Event;
	}, RemoteEventMock)
end

function RemoteEventMock:FireClient(client, ...)
	local remoteEvent = self._connectedClients[client]
	if remoteEvent then
		remoteEvent.clientEvent:Fire(...)
	end
end

function RemoteEventMock:FireAllClients(...)
	for _, remoteEvent in pairs(self._connectedClients) do
		remoteEvent.clientEvent:Fire(...)
	end
end

function RemoteEventMock:FireServer(...)
	self._serverRemoteEvent.serverEvent:Fire(self._localClient, ...)
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