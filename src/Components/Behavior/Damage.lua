local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local Definitions = require(script.Parent.Parent.Parent.Shared.Definitions)

return newComponent("Damage", {
	defaults = {
		amount = math.huge;
		cooldown = 0;
		damage = 0;
		timestamp = 0;
	};

	schema = {
		amount = t.number;
		cooldown = t.number;
		damage = t.number;
		filter = t.string;
		damageType = Definitions.damageType;
		timestamp = t.number;
		removeOnNoDamage = t.optional(t.boolean);
	};
})