local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local function applyExplosion(world, components, params)
	for id, explodeOnTouch, part in world:query(components.ExplodeOnTouch, components.Part, components.Local) do
		for _, hit in Matter.useEvent(part.part, explodeOnTouch.getTouchedSignal(part.part)) do
			if not explodeOnTouch.filter(hit) then continue end

			local collision = Instance.new("Part")
			collision.CFrame, collision.Size = explodeOnTouch.transform(
				part.part.CFrame, Vector3.one * explodeOnTouch.radius
			)

			collision.Transparency = 1
			collision.Anchored = true
			collision.CanCollide = false
			collision.Shape = Enum.PartType.Ball
			collision.Parent = workspace

			local newId = params.Crossbow:SpawnBind(
				collision,
				components.Local(),
				components.Lifetime({
					duration = 0;
					timestamp = params.currentFrame;
				}),
				params.Packs.Explosion(explodeOnTouch.damage)
			)

			local pos = collision.CFrame.Position
			params.events:fire("queueRemove", id)
			params.events:fire("playSound", "rocketExplode", pos)
			params.events:fire("exploded", newId, id, pos)
			return
		end
	end
end

return {
	system = applyExplosion;
	event = "PreSimulation";
	priority = Priorities.Projectiles;
}