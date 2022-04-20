local Priorities = require(script.Parent.Parent.Priorities)

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function removedQueued(world, components, params)
	local query = useHookStorage()

	for id in world:query(components.LagCompensation) do
		world:remove(id, components.LagCompensation)
	end

	for _, id in params.events:iterate("queueRemove") do
		if world:contains(id) then
			world:despawn(id)
		end
	end

	for id, lifetimeRecord in world:queryChanged(components.Lifetime) do
		if lifetimeRecord.new then
			query[id] = lifetimeRecord.new
		else
			query[id] = nil
		end
	end
	
	for id, lifetime in pairs(query) do
		-- Use > so a duration of 0 still waits a frame.
		if params.currentFrame - lifetime.timestamp > lifetime.duration then
			world:despawn(id)
		end
	end

	for _id, instanceRecord in world:queryChanged(components.Instance) do
		if instanceRecord.new == nil then
			instanceRecord.old.instance.Parent = nil
		end
	end

	for _id, partRecord in world:queryChanged(components.Part) do
		if partRecord.new == nil then
			partRecord.old.part.Parent = nil
		end
	end
end

return {
	system = removedQueued;
	event = "PostSimulation";
	priority = Priorities.CoreAfter + 9;
}