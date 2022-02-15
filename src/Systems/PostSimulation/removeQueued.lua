local function removedQueued(world, components)
	for id, record in world:queryChanged(components.Exists) do
		if record.new == nil then
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
	priority = 100;
}