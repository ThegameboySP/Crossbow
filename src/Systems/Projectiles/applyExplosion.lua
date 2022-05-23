local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function applyExplosion(world, params)
	for id, part, explodeOnTouch in world:query(Components.Part, Components.ExplodeOnTouch, Components.Owned) do
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

		local newId = params.Crossbow:SpawnBind(collision, params.Packs.Explosion(damage))

		if isOwned then
			world:insert(newId, Components.Owned())
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