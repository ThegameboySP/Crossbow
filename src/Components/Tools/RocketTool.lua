local General = require(script.Parent.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("RocketTool", {
		toolType = "Projectile";
		getProjectileCFrame = General.getProjectileCFrame;

		index = {
			raycastFilter = settings.RocketTool.raycastFilter;
			velocity = settings.RocketTool.velocity;
			spawnDistance = settings.RocketTool.spawnDistance;
			prefab = settings.RocketTool.prefab;
			pack = settings.RocketTool.pack;
		};
	})
end