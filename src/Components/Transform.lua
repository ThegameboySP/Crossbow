local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return newComponent("Transform", {
	schema = t.strictInterface({
		cframe = t.CFrame;
		doNotReconcile = t.optional(t.boolean);
	});
})