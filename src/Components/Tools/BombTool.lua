local General = require(script.Parent.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("BombTool", {
		getProjectileCFrame = General.getProjectileCFrameTop;

		index = {
			reloadTime = settings.BombTool.reloadTime;
			spawnDistance = settings.BombTool.spawnDistance;
			prefab = settings.BombTool.prefab;
			pack = settings.BombTool.pack;
		};
	})
end