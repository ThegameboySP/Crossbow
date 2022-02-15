local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Part", {
		schema = {
			part = t.instanceIsA("BasePart");
		};
	})
end