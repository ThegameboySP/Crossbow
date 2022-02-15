local CollectionService = game:GetService("CollectionService")

local function applyTags(world, components)
	for _id, projectileRecord, instance in world:queryChanged(components.Projectile, components.Instance) do
		if projectileRecord.new then
			CollectionService:AddTag(instance.instance, "Projectile")
		else
			CollectionService:RemoveTag(instance.instance, "Projectile")
		end
	end

	for _id, toolRecord, instance in world:queryChanged(components.Tool, components.Instance) do
		if toolRecord.new then
			CollectionService:AddTag(instance.instance, "Tool")
		else
			CollectionService:RemoveTag(instance.instance, "Tool")
		end
	end
end

return {
	system = applyTags;
	event = "PreSimulation";
	priority = 100;
}