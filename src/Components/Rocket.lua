local Matter = require(script.Parent.Parent.Parent.Matter)
local t = require(script.Parent.Parent.Parent.t)

local Projectile = require(script.Parent.Projectile)
local Layers = require(script.Parent.Parent.Utilities.Layers)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return newComponent("Rocket", {
	defaults = {
		damage = Layers.new({100})
	};

	schema = t.strictInterface({
		damage = Layers.validator(t.number);
	})
	-- defaults = Matter.merge(Projectile.inheritedDefaults, {
		
	-- });
	
	-- schema = t.strictInterface(Matter.merge(Projectile.inheritedSchema, {
		
	-- }));
})