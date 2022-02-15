local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Instance", {
		schema = {
			instance = t.Instance;
		};
	})
end