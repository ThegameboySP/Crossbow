local Priorities = require(script.Parent.Parent.Priorities)
local updateToolActions = require(script.Parent.updateToolActions)

local delta = {}

local function updateTools(world, components, params)
	for id, tool, instance in world:query(components.Tool, components.Instance) do
		if not tool.character then continue end

		local isEquipped = instance.instance.Parent == tool.character
		if tool.isEquipped ~= isEquipped then
			delta.isEquipped = isEquipped
			
			if isEquipped and not params.Crossbow.IsServer then
				if tool.equipSound then
					params.soundPlayer:queueSound(tool.equipSound, id, world:get(id, components.Part).part.Position, 1)
				end
			end
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
	after = { updateToolActions };
	priority = Priorities.Tools;
}
