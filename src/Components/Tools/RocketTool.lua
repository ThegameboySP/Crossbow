local General = require(script.Parent.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local t = require(script.Parent.Parent.Parent.Parent.t)

return newComponent("RocketTool", {
	toolType = "Projectile";
	getProjectileCFrame = General.getProjectileCFrame;

	schema = {
		raycastFilter = t.string;
		velocity = t.number;
		spawnDistance = t.number;
		prefab = t.Instance;
		pack = t.string;
	};
})