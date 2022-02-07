local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return newComponent("Part", {
	schema = t.strictInterface({
		part = t.instanceIsA("BasePart");
	});
})