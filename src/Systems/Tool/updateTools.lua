local Priorities = require(script.Parent.Parent.Priorities)

local delta = {}

local function updateTools(world, components, params)
	for id, tool, instance in world:query(components.Tool, components.Instance) do
		if not tool.character then continue end

		local isEquipped = instance.instance.Parent == tool.character
		if tool.isEquipped ~= isEquipped then
			delta.isEquipped = isEquipped
		end

		if tool.reloadTimeLeft > 0 then
			delta.reloadTimeLeft = math.max(0, tool.reloadTimeLeft - params.deltaTime)
		end

		if next(delta) then
			world:insert(id, tool:patch(delta))
			table.clear(delta)
		end
	end
end

return {
	system = updateTools;
	event = "PreSimulation";
	priority = Priorities.Tools;
}
