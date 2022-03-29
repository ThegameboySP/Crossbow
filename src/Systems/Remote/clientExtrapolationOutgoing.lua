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

		for id, part in world:query(components.Part, components.Projectile, components.Owned):without(components.Rocket) do
			local position = part.part.Position
			table.insert(packets, {id, position})
		end

		if packets[1] then
			params.remoteEvents:fire("out", "extrap-update", packets)
		end
	end

	for id, projectileRecord, part in world:queryChanged(components.Projectile, components.Part, components.Owned) do
		if projectileRecord.new and not projectileRecord.old then
			localIds[id] = true

			params.remoteEvents:fire(
				"out",
				"extrap-projectileSpawned",
				params.clientToServerId[projectileRecord.new.spawnerId],
				id,
				params.currentFrame,
				projectileRecord.new.componentName,
				part.part.CFrame
			)
		elseif not projectileRecord.new and projectileRecord.old then
			params.remoteEvents:fire("out", "extrap-projectileRemoved", id)
		end
	end

	for id, projectileRecord in world:queryChanged(components.Projectile) do
		if 
			not projectileRecord.new and projectileRecord.old
			and localIds[id]
		then
			params.remoteEvents:fire("out", "extrap-projectileRemoved", id)
			localIds[id] = nil
		end
	end

	for _, record in params.events:iterate("damaged") do
		params.remoteEvents:fire("out", "extrap-damaged", record.humanoid, record.damageComponent.damage, record.damageComponent.damageType)
	end

	for _, event in params.events:iterate("exploded") do
		if
			not event.isOwned
			or not world:contains(event.spawnerId)
			or not world:get(event.spawnerId, components.Projectile)
		then
			continue
		end
		
		params.remoteEvents:fire("out", "extrap-exploded", event.position, event.radius, event.spawnerId)
	end
end

return {
	realm = "client";
	system = clientExtrapolationOutgoing;
	event = "PostSimulation";
	priority = Priorities.CoreAfter + 8;
}