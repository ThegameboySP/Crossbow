local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return newComponent("LagCompensation", {
	schema = {
		timestamp = t.number;
	};
})