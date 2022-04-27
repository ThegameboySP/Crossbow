local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Ricochets", {
		schema = {
			damageMultiplier = t.number;
			filter = t.string;
			maxRicochets = t.number;
			ricochets = t.number;
			debounce = t.number;
			timestamp = t.number;
			ricochetSound = t.optional(t.Instance);
		};
	})
end