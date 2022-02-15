local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Lifetime", {
		schema = {
			duration = t.number;
			timestamp = t.number;
		};
	})
end