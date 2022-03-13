local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function clientExtrapolationOutgoing(world, components, params)
	if params.Settings.Network.netMode:Get() ~= "Extrapolation" then
		return
	end

	local localIds = useHookStorage()

	if Matter.useThrottle(params.Settings.Network.extrapolationFrequency:Get()) then
		local packets = {}

		for id, part in world:query(components.Part, components.Projectile, components.Local):without(components.Rocket) do
			local position = part.part.Position
			table.insert(packets, {id, position})
		end

		if packets[1] then
			params.events:fire("remote", "extrap-update", packets)
		end
	end

	for id, projectileRecord, part in world:queryChanged(components.Projectile, components.Part, components.Local) do
		if projectileRecord.new and not projectileRecord.old then
			localIds[id] = true

			params.events:fire(
				"remote",
				"extrap-projectileSpawned",
				params.clientToServerId[projectileRecord.new.spawnerId],
				id,
				params.currentFrame,
				projectileRecord.new.componentName,
				part.part.CFrame
			)
		elseif not projectileRecord.new and projectileRecord.old then
			params.events:fire("remote", "extrap-projectileRemoved", id)
		end
	end

	for id, projectileRecord in world:queryChanged(components.Projectile) do
		if 
			not projectileRecord.new and projectileRecord.old
			and localIds[id]
		then
			params.events:fire("remote", "extrap-projectileRemoved", id)
			localIds[id] = nil
		end
	end

	for character, damage in params.events:iterate("damaged") do
		params.events:fire("remote", "extrap-damaged", character, damage.damage)
	end

	for _, pos, radius, _, isLocal, spawnerId in params.events:iterate("exploded") do
		if not isLocal or not world:get(spawnerId, components.Projectile) then
			continue
		end
		
		params.events:fire("remote", "extrap-exploded", pos, radius, spawnerId)
	end
end

return {
	realm = "client";
	system = clientExtrapolationOutgoing;
	event = "PostSimulation";
	priority = Priorities.CoreAfter + 8;
}