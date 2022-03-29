local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("ExplodeCountdown", {
        schema = {
            tickColors = t.array(t.Color3);
            startingInterval = t.number;
            multiplier = t.union(t.numberMinExclusive(0), t.numberMaxExclusive(1));
            radius = t.number;
            explodeSound = t.optional(t.Instance);
            tickSound = t.optional(t.Instance);
        }
    })
end