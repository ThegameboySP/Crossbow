local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)
local t = require(script.Parent.Parent.Parent.Parent.t)

return newComponent("TrowelWall", {
	schema = {
		normal = t.Vector3;
		part = t.Instance;
		spawnerId = t.number;
	}
})