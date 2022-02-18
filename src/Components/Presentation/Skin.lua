local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Skin", {
		schema = {
			explosionDecorator = t.optional(t.callback);
			projectileDecorator = t.optional(t.callback);
		};
	})
end