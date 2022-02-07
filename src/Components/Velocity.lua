local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return newComponent("Velocity", {
	schema = t.strictInterface({
		velocity = t.Vector3;
	});
})