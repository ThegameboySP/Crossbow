local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function clientExtrapolationIncoming(world, components, params)
	if params.Settings.Network.netMode:Get() ~= "Extrapolation" then
		return
	end

	local proxyToClientId = useHookStorage()

	for _, spawnerId in params.remoteEvents:iterate("in-extrap-projectileFailed") do
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
		local tool = world:get(spawnerClientId, components.Tool)

		local specificTool = world:get(spawnerClientId, components[tool.componentName])
		local id = world:spawn(specificTool.pack(spawnerClientId, tool.character, velocity, cframe))

		proxyToClientId[proxyId] = id

		if name == "Rocket" then
			local delta = params.currentFrame - timestamp

			world:insert(id, components.Transform({
				cframe = cframe * CFrame.new(-Vector3.zAxis * delta * velocity)
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