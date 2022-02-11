local Components = require(script.Parent.Parent.Parent.Components)

local function removedQueued(world)
	for id, record in world:queryChanged(Components.Exists) do
		if record.new == nil then
			world:despawn(id)
		end
	end

	for _id, instanceRecord in world:queryChanged(Components.Instance) do
		if instanceRecord.new == nil then
			instanceRecord.old.instance:Destroy()
		end
	end

	for _id, partRecord in world:queryChanged(Components.Part) do
		if partRecord.new == nil then
			partRecord.old.part:Destroy()
		end
	end
end

return {
	system = removedQueued;
	event = "PostSimulation";
	priority = 100;
}