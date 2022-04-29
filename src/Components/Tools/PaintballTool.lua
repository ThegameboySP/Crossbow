local General = require(script.Parent.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function(settings)
	return newComponent("PaintballTool", {
		toolType = "Projectile";
        getProjectileCFrame = General.getProjectileCFrame;

		index = {
			raycastFilter = settings.PaintballTool.raycastFilter;
			velocity = settings.PaintballTool.velocity;
			spawnDistance = settings.PaintballTool.spawnDistance;
			prefab = settings.PaintballTool.prefab;
			pack = settings.PaintballTool.pack;
		};
	})
end