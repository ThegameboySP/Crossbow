local Components = require(script.Parent.Parent.Components)
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

		crossbowServer.World:spawn(
			Components.Exists(),
			Components.Instance({
				instance = Instance.new("Folder");
			})
		)

		runServer()
		runClient()
		expect(crossbowClient.World:get(0, Components.Exists)).to.be.ok()
	end)

	it("should replicate current state to client who is just connecting", function()
		local runServer, crossbowServer, newClient = createNetworkEnvironment({serverReplication, fireRemotes})
		runServer()

		crossbowServer.World:spawn(
			Components.Exists(),
			Components.Instance({
				instance = Instance.new("Folder");
			})
		)

		local runClient, crossbowClient = newClient({getRemotes, clientReplication})
		
		runClient()
		runServer()
		runClient()
		expect(crossbowClient.World:get(0, Components.Exists)).to.be.ok()
	end)
end