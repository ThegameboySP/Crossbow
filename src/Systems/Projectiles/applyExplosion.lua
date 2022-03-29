local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local function applyExplosion(world, components, params)
	for id, explodeOnTouch, part in world:query(components.ExplodeOnTouch, components.Part, components.Owned) do
		for _, hit in Matter.useEvent(part.part, explodeOnTouch.getTouchedSignal(part.part)) do
			if not params.Settings.Callbacks[explodeOnTouch.filter](hit) then
				continue
			end

			local pos = params.Settings.Callbacks[explodeOnTouch.transform](part.part)
			params.events:fire("explosion", pos, explodeOnTouch.radius, explodeOnTouch.damage, true, id)
			params.events:fire("queueRemove", id)
			if explodeOnTouch.explodeSound then
				params.events:fire("playSound", explodeOnTouch.explodeSound, part.part.Position, id)
			end

			break
		end
	end

	for _, pos, radius, damage, isOwned, spawnerId, soundValue in params.events:iterate("explosion") do
		local collision = Instance.new("Part")
		collision.CFrame = CFrame.new(pos)
		collision.Size = Vector3.one * radius * 2

		collision.Transparency = 1
		collision.CanQuery = false
		collision.Anchored = true
		collision.CanCollide = false
		collision.Shape = Enum.PartType.Ball
		collision.Parent = workspace

		if soundValue then
			params.events:fire("queueSound", soundValue, spawnerId, pos)
		end

		local newId = params.Crossbow:SpawnBind(
			collision,
			components.Lifetime({
				duration = 0;
				timestamp = params.currentFrame;
			})
		)

		if isOwned then
			world:insert(newId, components.Owned(), params.Packs.Explosion(damage))
		end

		params.events:fire("exploded", table.freeze({
			spawnerId = spawnerId;
			newId = newId;
			position = pos;
			radius = radius;
			damage = damage;
			isOwned = isOwned;
		}))
	end
end

return {
	system = applyExplosion;
	event = "PreSimulation";
	priority = Priorities.Projectiles + 9;
}