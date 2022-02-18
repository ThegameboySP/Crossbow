local General = require(script.Parent.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("SuperballTool", {
		getProjectileCFrame = General.getProjectileCFrame;

		index = {
			raycastFilter = settings.SuperballTool.raycastFilter;
			reloadTime = settings.SuperballTool.reloadTime;
			velocity = settings.SuperballTool.velocity;
			spawnDistance = settings.SuperballTool.spawnDistance;
			prefab = settings.SuperballTool.prefab;
			pack = settings.SuperballTool.pack;
		};
	})
end