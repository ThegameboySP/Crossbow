local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local Definitions = require(script.Parent.Parent.Parent.Shared.Definitions)

return function()
	return newComponent("Damage", {
		defaults = {
			amount = math.huge;
			cooldown = 0;
			damage = 0;
			filter = function() return true end;
			damagedTimestamp = math.huge;
		};

		schema = {
			amount = t.number;
			cooldown = t.number;
			damage = t.number;
			filter = t.callback;
			damageType = Definitions.damageType;
			damagedTimestamp = t.number;
		};
	})
end