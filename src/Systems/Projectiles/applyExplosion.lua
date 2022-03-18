local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local function applyExplosion(world, components, params)
	local Sounds = params.Settings.Sounds
	
	for id, explodeOnTouch, part in world:query(components.ExplodeOnTouch, components.Part, components.Local) do
		for _, hit in Matter.useEvent(part.part, explodeOnTouch.getTouchedSignal(part.part)) do
			if not explodeOnTouch.filter(hit) then
				continue
			end

			local pos = explodeOnTouch.transform(part.part)
			params.events:fire("explosion", pos, explodeOnTouch.radius, explodeOnTouch.damage, true, id)
			params.events:fire("queueRemove", id)
			break
		end
	end

	for _, pos, radius, damage, isLocal, spawnerId in params.events:iterate("explosion") do
		local collision = Instance.new("Part")
		collision.CFrame = CFrame.new(pos)
		collision.Size = Vector3.one * radius * 2

		collision.Transparency = 1
		collision.CanQuery = false
		collision.Anchored = true
		collision.CanCollide = false
		collision.Shape = Enum.PartType.Ball
		collision.Parent = workspace

		local newId = params.Crossbow:SpawnBind(
			collision,
			components.Lifetime({
				duration = 0;
				timestamp = params.currentFrame;
			})
		)

		if isLocal then
			world:insert(newId, components.Local(), params.Packs.Explosion(damage))
		end

		params.events:fire("playSound", Sounds.rocketExplode, pos)
		params.events:fire("exploded", table.freeze({
			spawnerId = spawnerId;
			newId = newId;
			position = pos;
			radius = radius;
			damage = damage;
			isLocal = isLocal;
		}))
	end
end

return {
	system = applyExplosion;
	event = "PreSimulation";
	priority = Priorities.Projectiles;
}