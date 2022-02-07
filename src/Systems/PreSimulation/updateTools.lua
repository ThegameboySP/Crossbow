local Components = require(script.Parent.Parent.Parent.Components)

local function updateTools(world)
	for id, tool, instance in world:query(Components.Tool, Components.Instance) do
		if not tool.character then continue end

		local isEquipped = instance.instance.Parent == tool.character
		if tool.isEquipped ~= isEquipped then
			world:insert(id, tool:patch({
				isEquipped = isEquipped;
			}))
		end
	end
end

return {
	system = updateTools;
	event = "PreSimulation";
}
