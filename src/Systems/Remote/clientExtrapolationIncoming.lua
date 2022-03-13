local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function clientExtrapolationIncoming(world, components, params)
	if params.Settings.Network.netMode:Get() ~= "Extrapolation" then
		return
	end

	local proxyToClientId = useHookStorage()

	for spawnerId in params.events:iterate("remote-extrap-projectileFailed") do
		params.events:fire("queueRemove", spawnerId)
	end

	-- TODO
	for packets in params.events:iterate("remote-extrap-update") do
		for _, packet in pairs(packets) do
			local serverId, position = unpack(packet)
			
		end
	end

	for spawnerId, proxyId, timestamp, name, velocity, cframe in params.events:iterate("remote-extrap-projectileSpawned") do
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

	for pos, radius, spawnerId in params.events:iterate("remote-extrap-exploded") do
		params.events:fire("explosion", pos, radius, 0, false, proxyToClientId[spawnerId])
	end

	for id in params.events:iterate("remote-extrap-projectileRemoved") do
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