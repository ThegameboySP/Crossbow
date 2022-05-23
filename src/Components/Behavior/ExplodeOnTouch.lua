local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return newComponent("ExplodeOnTouch", {
	schema = {
		filter = t.string;
		radius = t.number;
		damage = t.number;
		transform = t.string;
		explodeSound = t.optional(t.Instance);
	};
})