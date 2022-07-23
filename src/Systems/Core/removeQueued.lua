local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Components = require(script.Parent.Parent.Parent.Components)

local function removedQueued(world, params)
	local query = useHookStorage()

	for id, lifetimeRecord in world:queryChanged(Components.Lifetime) do
		if lifetimeRecord.new then
			query[id] = lifetimeRecord.new
		else
			query[id] = nil
		end
	end
	
	local currentFrame = params.currentFrame
	for id, lifetime in pairs(query) do
		if (currentFrame - lifetime.timestamp) >= lifetime.duration then
            params.events:fire("queueRemove", id)
		end
	end

	table.clear(params.removedBins)

	for _, id in params.events:iterate("queueRemove") do
		if world:contains(id) then
			local bin = {}
			params.removedBins[id] = bin

			for _, metatable in pairs(Components) do
				bin[metatable] = world:get(id, metatable)
			end

			world:despawn(id)
		end
	end

	for _id, instanceRecord in world:queryChanged(Components.Instance) do
		if instanceRecord.new == nil and instanceRecord.old then
			instanceRecord.old.instance.Parent = nil
		end
	end

	for id in world:query(Components.LagCompensation) do
		world:remove(id, Components.LagCompensation)
	end
end

return {
	system = removedQueued;
	event = "PostSimulation";
	priority = Priorities.CoreAfter + 9;
}