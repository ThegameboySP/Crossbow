local Priorities = require(script.Parent.Parent.Priorities)

local function patchComponents(components, world, id, remoteComponents)
	local toUnpack = {}
	
	for name, body in pairs(remoteComponents) do
		local instance = world:get(id, components[name])
		if instance then
			table.insert(toUnpack, instance:patch(body))
		else
			table.insert(toUnpack, components[name].new(body))
		end
	end

	return unpack(toUnpack)
end

local function createNewComponents(components, remoteComponents)
	local toUnpack = {}
	for name, body in pairs(remoteComponents) do
		table.insert(toUnpack, components[name](body))
	end
	return unpack(toUnpack)
end

local function clientReplication(world, components, params)
	for newComponents, removedComponents in params.events:iterate("remote-replication") do
		for id, name in pairs(removedComponents) do
			world:remove(serverToClientId[id], components[name])
		end

		for id, remoteComponents in pairs(newComponents) do
			if remoteComponents.Instance then
				local instance = remoteComponents.Instance.instance
				if instance == nil then
					warn(string.format("%d.Instance: instance doesn't exist in this realm.", id))
					continue
				end
				
				local entityId = instance:GetAttribute(params.entityKey)
				if entityId then
					world:insert(entityId, patchComponents(components, world, entityId, remoteComponents))
				else
					entityId = world:spawn(createNewComponents(components, remoteComponents))
					params.Crossbow:Bind(instance, entityId)
				end
			else
				warn("Can't replicate entity: it has no attached Instance.")
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