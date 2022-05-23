local General = require(script.Parent.Parent.Parent.Utilities.General)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local t = require(script.Parent.Parent.Parent.Parent.t)

return newComponent("BombTool", {
	toolType = "Projectile";
	getProjectileCFrame = General.getProjectileCFrameTop;

	schema = {
		spawnDistance = t.number;
		prefab = t.Instance;
		pack = t.string;
	};
})