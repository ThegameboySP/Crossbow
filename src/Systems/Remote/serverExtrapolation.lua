local Players = game:GetService("Players")

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function serverExtrapolation(world, components, params)
	local NetworkSettings = params.Settings.Network
	if NetworkSettings.netMode:Get() ~= "Extrapolation" then
		return
	end

	local clientToProxyId = useHookStorage()

	-- TODO
	-- for client, packets in params.events:iterate("remote-extrap-update") do
	-- 	if type(packets) ~= "table" then
	-- 		continue
	-- 	end

	-- 	for _, packet in pairs(packets) do
	-- 		local clientId, cframe = unpack(packet)
	-- 		-- if not world:contains(serverId) then
	-- 		-- 	warn(string.format("Server does not contain entity %q", tostring(serverId)))
	-- 		-- 	continue
	-- 		-- end

	-- 		-- local projectile = world:get(serverId, components.Projectile)
	-- 		-- if projectile == nil then
	-- 		-- 	warn(string.format("%d.Projectile does not exist", serverId))
	-- 		-- 	continue
	-- 		-- end

	-- 		-- local owner = world:get(serverId, components.Owner)
	-- 		-- if owner == nil or owner.client ~= client then
	-- 		-- 	warn(string.format("%q does not own this projectile", client.Name))
	-- 		-- 	continue
	-- 		-- end

	-- 		-- local transform = world:get(serverId, components.Transform)

	-- 		for _, player in pairs(Players:GetPlayers()) do
	-- 			if player ~= client then
	-- 				params.events:fire(
	-- 					"remote",
	-- 					"extrap-update",
	-- 					player,
	-- 					serverId,
	-- 					cframe
	-- 				)
	-- 			end
	-- 		end
	-- 	end
	-- end

	for client, spawnerId, projId, timestamp, name, cframe in params.events:iterate("remote-extrap-projectileSpawned") do
		local tool = world:contains(spawnerId) and world:get(spawnerId, components.Tool)

		if
			not tool
			or client ~= Players:GetPlayerFromCharacter(tool.character)
			or not tool:canFire()
		then
			params.events:fire("remote", "extrap-projectileFailed", client, projId)
			continue
		end

		local serverId = world:spawn()
		clientToProxyId[client] = clientToProxyId[client] or {}
		clientToProxyId[client][projId] = serverId

		local specificTool = world:get(spawnerId, components[tool.componentName])
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= client then
				params.events:fire(
					"remote",
					"extrap-projectileSpawned",
					player,
					spawnerId,
					serverId,
					timestamp,
					name,
					specificTool.velocity,
					cframe
				)
			end
		end
	end

	for client, id in params.events:iterate("remote-extrap-projectileRemoved") do
		if clientToProxyId[client] == nil then
			continue
		end

		local proxyId = clientToProxyId[client][id]
		if proxyId == nil then
			continue
		end

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= client then
				params.events:fire("remote", "extrap-projectileRemoved", player, proxyId)
			end
		end
	end

	for client, pos, radius, spawnerId in params.events:iterate("remote-extrap-exploded") do
		if clientToProxyId[client] == nil then
			continue
		end

		local proxyId = clientToProxyId[client][spawnerId]
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= client then
				params.events:fire("remote", "extrap-exploded", player, pos, radius, proxyId)
			end
		end
	end
end

return {
	realm = "server";
	system = serverExtrapolation;
	event = "PostSimulation";
}