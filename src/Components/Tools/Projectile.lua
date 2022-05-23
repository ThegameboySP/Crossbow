local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return newComponent("Projectile", {
	replicate = function(crossbow, remote)
		if remote.spawnerId == nil then
			return remote
		end

		remote.spawnerId = crossbow.Params.serverToClientId[remote.spawnerId]
		return remote
	end;

	schema = {
		componentName = t.string;
		character = t.optional(t.Instance);
		spawnerId = t.number;
	};
})