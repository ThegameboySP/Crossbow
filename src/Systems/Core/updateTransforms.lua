local Priorities = require(script.Parent.Parent.Priorities)

local function updateTransforms(world, components)
	for id, part, transform in world:query(components.Part, components.Transform) do
		local existingCFrame = transform.cframe
		local currentCFrame = part.part.CFrame

		if currentCFrame ~= existingCFrame then
			world:insert(
				id,
				components.Transform({
					cframe = currentCFrame,
					doNotReconcile = true,
				})
			)
		end
	end
end

return {
	system = updateTransforms;
	event = "PostSimulation";
	priority = Priorities.CoreBefore;
}
