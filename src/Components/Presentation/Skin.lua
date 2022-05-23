local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return newComponent("Skin", {
	schema = {
		explosionDecorator = t.optional(t.string);
		projectileDecorator = t.optional(t.string);
	};
})