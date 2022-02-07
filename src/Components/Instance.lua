local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return newComponent("Instance", {
	schema = t.strictInterface({
		instance = t.Instance;
	})
})