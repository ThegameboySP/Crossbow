local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return newComponent("Owner", {
	schema = {
		client = t.instanceIsA("Player");
	}
})