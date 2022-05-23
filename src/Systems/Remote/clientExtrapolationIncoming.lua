local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Components = require(script.Parent.Parent.Parent.Components)

local function clientExtrapolationIncoming(world, params)
	if params.Settings.Network.netMode:Get() ~= "Extrapolation" then
		return
	end

	local proxyToClientId = useHookStorage()

	for _, instance, packId, character in params.remoteEvents:iterate("in-extrap-newTool") do
		params.Crossbow:SpawnBind(instance, params.Packs[packId](character))
	end

	for _, spawnerId in params.remoteEvents:iterate("in-extrap-projectileFailed") do
		warn("projectile failed", spawnerId)
		params.events:fire("queueRemove", spawnerId)
	end

	-- TODO
	for _, packets in params.remoteEvents:iterate("in-extrap-update") do
		for _, packet in pairs(packets) do
			local serverId, position = unpack(packet)
			
		end
	end

	for _, spawnerId, proxyId, timestamp, name, velocity, cframe in params.remoteEvents:iterate("in-extrap-projectileSpawned") do
		local spawnerClientId = params.serverToClientId[spawnerId]
		local tool = world:get(spawnerClientId, Components.Tool)

		local specificTool = world:get(spawnerClientId, Components[tool.componentName])
		local id = world:spawn(specificTool.pack(spawnerClientId, tool.character, velocity, cframe))

		proxyToClientId[proxyId] = id

		if useExtrapolation or name == "Rocket" then
			world:insert(id, Components.LagCompensation({
				timestamp = timestamp;
			}))
		end
	end

	for _, pos, radius, spawnerId in params.remoteEvents:iterate("in-extrap-exploded") do
		params.events:fire("explosion", pos, radius, 0, false, proxyToClientId[spawnerId])
	end

	for _, id in params.remoteEvents:iterate("in-extrap-projectileRemoved") do
		params.events:fire("queueRemove", proxyToClientId[id])
		proxyToClientId[id] = nil
	end
end

return {
	realm = "client";
	system = clientExtrapolationIncoming;
	event = "PreSimulation";
	priority = Priorities.RemoteBefore + 2;
}