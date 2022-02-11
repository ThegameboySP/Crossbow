local Matter = require(script.Parent.Parent.Parent.Matter)
local t = require(script.Parent.Parent.Parent.t)

local Prefabs = script.Parent.Parent.Assets.Prefabs
local Tool = require(script.Parent.Tool)
local Packs = require(script.Parent.Parent.Shared.Packs)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

local RocketTool = newComponent("RocketTool", {
	getProjectileCFrame = Tool.getProjectileCFrame;

	defaults = Matter.merge(Tool.inheritedDefaults, {
		reloadTime = 7;
		velocity = 60;
		spawnDistance = 6;

		prefab = Prefabs.Rocket;

		pack = Packs.RocketTool;
		projectilePack = Packs.Rocket;
	});
	
	schema = t.strictInterface(Matter.merge(Tool.inheritedSchema, {
		reloadTime = t.number;
		velocity = t.number;
		spawnDistance = t.number;
		pack = t.callback;
		projectilePack = t.callback;
		prefab = t.instanceIsA("BasePart");
	}));
})

return RocketTool