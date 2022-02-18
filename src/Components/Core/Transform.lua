local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Transform", {
		schema = {
			cframe = t.CFrame;
			doNotReconcile = t.optional(t.boolean);
		};
	})
end