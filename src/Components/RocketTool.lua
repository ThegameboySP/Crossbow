local General = require(script.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("RocketTool", {
		getProjectileCFrame = General.getProjectileCFrame;

		index = {
			reloadTime = settings.RocketTool.reloadTime;
			velocity = settings.RocketTool.velocity;
			spawnDistance = settings.RocketTool.spawnDistance;
			prefab = settings.RocketTool.prefab;
			pack = settings.RocketTool.pack;
		};
	})
end