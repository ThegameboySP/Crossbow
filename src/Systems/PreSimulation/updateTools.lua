local delta = {}

local function updateTools(world, components, params)
	for id, tool, instance in world:query(components.Tool, components.Instance) do
		if not tool.character then continue end

		local isEquipped = instance.instance.Parent == tool.character
		if tool.isEquipped ~= isEquipped then
			delta.isEquipped = isEquipped
		end

		if tool.reloading and tool.reloadTimeLeft - params.deltaTime <= 0 then
			delta.reloadTimeLeft = 0
			delta.reloading = false
		elseif tool.reloading then
			delta.reloadTimeLeft = tool.reloadTimeLeft - params.deltaTime
			-- print(params.deltaTime)
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
}
