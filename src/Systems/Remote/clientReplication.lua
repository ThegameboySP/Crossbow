local Players = game:GetService("Players")

local Priorities = require(script.Parent.Parent.Priorities)

local NULL = string.char(0)
local LOCAL_PLAYER = Players.LocalPlayer

local function transformToNil(t)
	for k, v in pairs(t) do
		if v == NULL then
			t[k] = nil
		end
	end

	return t
end

local function getNewComponents(world, components, id, remoteComponents)
	debug.profilebegin("replication: reconcile components")

	local newComponents = {}
	for name, body in pairs(remoteComponents) do
		local component = id and world:get(id, components[name])
		local replicateFn = components[name].replicate or function(...)
			return ...
		end

		if component then
			table.insert(newComponents, component:patch(replicateFn(transformToNil(body))))
		else
			table.insert(newComponents, components[name].new(replicateFn(transformToNil(body))))
		end
	end

	debug.profileend()

	return newComponents
end

local function clientReplication(world, components, params)
	local serverToClientId = params.serverToClientId
	local clientToServerId = params.clientToServerId

	for _, newComponents, removedComponents in params.remoteEvents:iterate("in-replication") do
		for _, entry in pairs(removedComponents) do
			local serverId, name = entry[1], entry[2]
			local clientId = serverToClientId[serverId]

			if clientId and world:contains(clientId) then
				if name == "Owner" then
					world:remove(clientId, components.Owned)
				end
				world:remove(clientId, components[name])

				clientToServerId[clientId] = nil
			end

			serverToClientId[serverId] = nil
		end

		for serverId, remoteComponents in pairs(newComponents) do
			serverId = tonumber(serverId)

			local clientId = serverToClientId[serverId]
			local instanceComponent = remoteComponents.Instance
			if instanceComponent == nil and clientId then
				instanceComponent = world:get(clientId, components.Instance)
			end

			if instanceComponent == nil then
				warn(string.format("Can't replicate server entity %d: it has no attached Instance.", serverId))
				continue
			end

			if instanceComponent.instance == nil then
				warn(string.format("Can't replicate server entity %d: Instance doesn't exist in this realm.", serverId))
				continue
			end

			if clientId == nil then
				clientId = params.Crossbow:SpawnBind(instanceComponent.instance)

				serverToClientId[serverId] = clientId
				clientToServerId[clientId] = serverId
			end
		end

		for serverId, remoteComponents in pairs(newComponents) do
			serverId = tonumber(serverId)
			
			local clientId = serverToClientId[serverId]
			local componentsToInsert = getNewComponents(world, components, clientId, remoteComponents)
			world:insert(clientId, unpack(componentsToInsert))

			if remoteComponents.Owner then
				if remoteComponents.Owner.client == LOCAL_PLAYER then
					world:insert(clientId, components.Owned())
				else
					world:remove(clientId, components.Owned)
				end
			end
		end
	end
end

return {
	realm = "client";
	system = clientReplication;
	event = "PreSimulation";
	priority = Priorities.RemoteBefore + 1;
}