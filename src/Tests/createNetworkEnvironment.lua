local Signal = require(script.Parent.Signal)
local createTestEnvironment = require(script.Parent.createTestEnvironment)

return function(serverSystems)
	local serverRun, serverCrossbow = createTestEnvironment(serverSystems, true)

	local clients = {}
	serverCrossbow.Params.getPlayers = function()
		return clients
	end

	local playerAdded = Signal.new()
	serverCrossbow.Params.playerAdded = playerAdded

	return serverRun, serverCrossbow, function(clientSystems)
		local clientRun, clientCrossbow = createTestEnvironment(clientSystems, false)
		local client = newproxy()
		local disconnect = serverCrossbow.Params.remoteEvent:connectClient(clientCrossbow.Params.remoteEvent, client)

		table.insert(clients, client)
		playerAdded:Fire(client)

		return clientRun, clientCrossbow, client, function()
			table.remove(clients, table.find(clients, client))
			disconnect()
		end
	end
end