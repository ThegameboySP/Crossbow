local Components = require(script.Parent.Parent.Parent.Components)

local function patchComponents(world, id, components)
	local toUnpack = {}
	for name, body in pairs(components) do
		table.insert(toUnpack, world:get(id, Components[name]):patch(body))
	end
	return unpack(toUnpack)
end

local function createNewComponents(components)
	local toUnpack = {}
	for name, body in pairs(components) do
		table.insert(toUnpack, Components[name](body))
	end
	return unpack(toUnpack)
end

local function clientReplication(world, params)
	for newComponents, removedComponents in params.events:iterate("remote-replication") do
		for id, name in pairs(removedComponents) do
			world:remove(serverToClientId[id], Components[name])
		end

		for id, components in pairs(newComponents) do
			if components.Instance then
				local instance = components.Instance.instance
				if instance == nil then
					warn(string.format("%d.Instance: instance doesn't exist in this realm.", id))
					continue
				end
				
				local entityId = instance:GetAttribute(params.entityKey)
				if entityId then
					world:insert(entityId, patchComponents(world, entityId, components))
				else
					world:spawn(createNewComponents(components))
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
	priority = -100;
}