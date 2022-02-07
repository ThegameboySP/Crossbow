local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return newComponent("Projectile", {
	schema = t.strictInterface({
		component = t.interface({
			patch = t.callback;
		});
		character = t.optional(t.Instance);
		spawnerId = t.number;
	});
})