local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Components = require(script.Parent.Parent.Parent.Components)

local function clientExtrapolationOutgoing(world, params)
	if params.Settings.Network.netMode:Get() ~= "Extrapolation" then
		return
	end

	local localIds = useHookStorage()

	if Matter.useThrottle(params.Settings.Network.extrapolationFrequency:Get()) then
		local packets = {}

		for id, part in world:query(Components.Part, Components.Projectile, Components.Owned):without(Components.Rocket) do
			local position = part.part.Position
			table.insert(packets, {id, position})
		end

		if packets[1] then
			params.remoteEvents:fire("out", "extrap-update", unpack(packets))
		end
	end

	for id, projectileRecord in world:queryChanged(Components.Projectile) do
		if not world:contains(id) then
			continue
		end
		
		local part = world:get(id, Components.Part)
		if not part or not world:get(id, Components.Owned) then
			continue
		end

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
			localIds[id] = nil
		end
	end

	for _, record in params.events:iterate("damaged") do
		params.remoteEvents:fire("out", "extrap-damaged", record)
	end

	for _, event in params.events:iterate("exploded") do
		if
			not event.isOwned
			or not world:contains(event.spawnerId)
			or not world:get(event.spawnerId, Components.Projectile)
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