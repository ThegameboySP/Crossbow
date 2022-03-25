local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local Definitions = require(script.Parent.Parent.Parent.Shared.Definitions)

return function()
	return newComponent("Damage", {
		defaults = {
			amount = math.huge;
			cooldown = 0;
			damage = 0;
			damagedTimestamp = 0;
		};

		schema = {
			amount = t.number;
			cooldown = t.number;
			damage = t.number;
			filter = t.string;
			damageType = Definitions.damageType;
			damagedTimestamp = t.number;
		};
	})
end