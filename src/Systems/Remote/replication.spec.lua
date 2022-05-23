local Components = require(script.Parent.Parent.Parent.Components)
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
		crossbowServer:SpawnBind(folder)

		runServer()
		runClient()
		expect(crossbowClient.World:get(0, Components.Instance)).to.be.ok()
		expect(folder:GetAttribute(crossbowClient.Params.entityKey)).to.equal(0)
	end)

	it("should replicate current state to client who is just connecting", function()
		local runServer, crossbowServer, newClient = createNetworkEnvironment({serverReplication, fireRemotes})
		runServer()

		local folder = Instance.new("Folder")
		crossbowServer:SpawnBind(folder)

		local runClient, crossbowClient = newClient({getRemotes, clientReplication})

		runClient()
		runServer()
		runClient()
		expect(crossbowClient.World:get(0, Components.Instance)).to.be.ok()
		expect(folder:GetAttribute(crossbowClient.Params.entityKey)).to.equal(0)
	end)
end