local Priorities = require(script.Parent.Parent.Priorities)

local function removedQueued(world, components, params)
	for id in world:query(components.LagCompensation) do
		world:remove(id, components.LagCompensation)
	end

	for _, id in params.events:iterate("queueRemove") do
		if world:contains(id) then
			world:despawn(id)
		end
	end

	for _id, instanceRecord in world:queryChanged(components.Instance) do
		if instanceRecord.new == nil then
			instanceRecord.old.instance.Parent = nil
		end
	end
end

return {
	system = removedQueued;
	event = "PostSimulation";
	priority = Priorities.CoreAfter + 9;
}