local Priorities = require(script.Parent.Parent.Priorities)

local function removedQueued(world, components, params)
	for id in params.events:iterate("queueRemove") do
		if world:contains(id) then
			world:despawn(id)
		end
	end

	for id, lifetime in world:query(components.Lifetime) do
		-- Use > so a duration of 0 still waits a frame.
		if params.currentFrame - lifetime.timestamp > lifetime.duration then
			world:despawn(id)
		end
	end

	for _id, instanceRecord in world:queryChanged(components.Instance) do
		if instanceRecord.new == nil then
			instanceRecord.old.instance:Destroy()
		end
	end

	for _id, partRecord in world:queryChanged(components.Part) do
		if partRecord.new == nil then
			partRecord.old.part:Destroy()
		end
	end
end

return {
	system = removedQueued;
	event = "PostSimulation";
	priority = Priorities.CoreAfter + 9;
}