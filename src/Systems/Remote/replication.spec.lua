local createNetworkEnvironment = require(script.Parent.Parent.Parent.Tests.createNetworkEnvironment)

local clientReplication = require(script.Parent.clientReplication)
local getRemotes = require(script.Parent.getRemotes)

local serverReplication = require(script.Parent.serverReplication)
local fireRemotes = require(script.Parent.fireRemotes)

return function()
	it("should replicate to client while client is already connected", function()
		local runServer, crossbowServer, newClient = createNetworkEnvironment({serverReplication, fireRemotes})
		local runClient, crossbowClient = newClient({getRemotes, clientReplication})

		runServer()
		runClient()

		local folder = Instance.new("Folder")
		local id = crossbowClient:SpawnBind(folder)
		
		crossbowServer:SpawnBind(folder)

		runServer()
		runClient()
		expect(crossbowClient.World:get(id, crossbowClient.Components.Instance)).to.be.ok()
		expect(folder:GetAttribute(crossbowClient.Params.entityKey)).to.equal(id)
	end)

	it("should replicate current state to client who is just connecting", function()
		local runServer, crossbowServer, newClient = createNetworkEnvironment({serverReplication, fireRemotes})
		runServer()

		local folder = Instance.new("Folder")
		crossbowServer:SpawnBind(folder)

		local runClient, crossbowClient = newClient({getRemotes, clientReplication})
		local id = crossbowClient:SpawnBind(folder)

		runClient()
		runServer()
		runClient()
		expect(crossbowClient.World:get(id, crossbowClient.Components.Instance)).to.be.ok()
		expect(folder:GetAttribute(crossbowClient.Params.entityKey)).to.equal(id)
	end)
end