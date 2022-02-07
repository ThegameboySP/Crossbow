local Components = require(script.Parent.Parent.Parent.Components)

local function updateTransforms(world)
	for id, part, transform in world:query(Components.Part, Components.Transform) do
		local existingCFrame = transform.cframe
		local currentCFrame = part.part.CFrame

		if currentCFrame ~= existingCFrame then
			world:insert(
				id,
				Components.Transform({
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
}
