local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("FixedVelocity", {
		schema = {
			velocity = t.Vector3;
		};
	})
end