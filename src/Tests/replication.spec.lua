local createNetworkEnvironment = require(script.Parent.createNetworkEnvironment)

local clientReplication = require(script.Parent.Parent.Systems.PreSimulation.clientReplication)
local getRemotes = require(script.Parent.Parent.Systems.PreSimulation.getRemotes)

local serverReplication = require(script.Parent.Parent.Systems.PostSimulation.serverReplication)
local fireRemotes = require(script.Parent.Parent.Systems.PostSimulation.fireRemotes)

return function()
	it("should replicate to client while client is already connected", function()
		local runServer, crossbowServer, newClient = createNetworkEnvironment({serverReplication, fireRemotes})
		local runClient, crossbowClient = newClient({getRemotes, clientReplication})

		runServer()
		runClient()

		local folder = Instance.new("Folder")
		local id = crossbowClient:SpawnBind(folder)
		
		crossbowServer:SpawnBind(folder, crossbowServer.Components.Exists())

		runServer()
		runClient()
		expect(crossbowClient.World:get(id, crossbowClient.Components.Exists)).to.be.ok()
		expect(folder:GetAttribute(crossbowClient.Params.entityKey)).to.equal(id)
	end)

	it("should replicate current state to client who is just connecting", function()
		local runServer, crossbowServer, newClient = createNetworkEnvironment({serverReplication, fireRemotes})
		runServer()

		local folder = Instance.new("Folder")
		crossbowServer:SpawnBind(folder, crossbowServer.Components.Exists())

		local runClient, crossbowClient = newClient({getRemotes, clientReplication})
		local id = crossbowClient:SpawnBind(folder)

		runClient()
		runServer()
		runClient()
		expect(crossbowClient.World:get(id, crossbowClient.Components.Exists)).to.be.ok()
		expect(folder:GetAttribute(crossbowClient.Params.entityKey)).to.equal(id)
	end)
end