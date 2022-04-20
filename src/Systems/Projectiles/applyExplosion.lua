local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local EventQueue = require(script.Parent.Parent.Parent.Utilities.EventQueue)

local function initState(state)
	state.touched = EventQueue.new()
end

local function applyExplosion(world, components, params)
	local touched = useHookStorage(nil, initState).touched
	local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()

	for id in world:queryChanged(components.Part) do
		touched:disconnect(id)
	end

	for id, record in world:queryChanged(components.ExplodeOnTouch) do
		if not record.new then
			touched:disconnect(id)
		end
	end

	for id, part, explodeOnTouch in world:query(components.Part, components.ExplodeOnTouch, components.Owned) do
		if not touched:isConnected(id) then
			touched:connect(id, getTouchedSignal(part.part))
			continue
		end

		for _, hit in touched:iterate(id) do
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