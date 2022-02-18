local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("Projectile", {
		schema = {
			component = t.interface({
				patch = t.callback;
			});
			character = t.optional(t.Instance);
			spawnerId = t.number;
		};
	})
end