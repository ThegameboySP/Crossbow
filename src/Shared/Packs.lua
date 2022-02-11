local function toolPack(componentName)
	return function(components, tool, character, params)
		local component = components[componentName]

		return
			components.Exists(),
			components.Tool({
				character = character;
				component = component;
			}),
			components.Instance({
				instance = tool;
			}),
			components.Local(),
			component(params)
	end
end

local function projectilePack(componentName)
	return function(components, spawnerId, tool, specificTool, spawnPos, params)
		local component = components[componentName]

		local cframe = specificTool.getProjectileCFrame(tool, specificTool.spawnDistance, spawnPos)
		return
			components.Exists(),
			components.Projectile({
				component = component;
				spawnerId = spawnerId;
			}),
			components.Transform({
				cframe = cframe
			}),
			components.Velocity({
				velocity = cframe.LookVector * specificTool.velocity;
			}),
			components.Local(),
			component(params)
	end
end

return {
	RocketTool = toolPack("RocketTool");
	Rocket = projectilePack("Rocket");
}