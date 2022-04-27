local Priorities = require(script.Parent.Parent.Priorities)

local function applyExplosion(world, components, params)
	for id, part, explodeOnTouch in world:query(components.Part, components.ExplodeOnTouch, components.Owned) do
		local queue = params.hitQueue[id]
		if queue == nil then
			continue
		end

		for _, hit in ipairs(queue) do
			if not params.Settings.Callbacks[explodeOnTouch.filter](hit) then
				continue
			end

			local pos = params.Settings.Callbacks[explodeOnTouch.transform](part.part)
			params.events:fire("explosion", pos, explodeOnTouch.radius, explodeOnTouch.damage, true, id, explodeOnTouch.explodeSound)
			params.events:fire("queueRemove", id)

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
			params.soundPlayer:queueSound(soundValue, nil, pos, 2)
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

		local event = table.freeze({
			spawnerId = spawnerId;
			newId = newId;
			position = pos;
			radius = radius;
			damage = damage;
			isOwned = isOwned;
		})

		params.events:fire("exploded", event)
	end
end

return {
	system = applyExplosion;
	event = "PreSimulation";
	priority = Priorities.Projectiles + 9;
}