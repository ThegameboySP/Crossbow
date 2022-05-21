local Priorities = require(script.Parent.Parent.Priorities)

local function showExplosions(world, components, params)
	for _, event in params.events:iterate("exploded") do
		local part = world:get(event.newId, components.Part).part

		local explosion = Instance.new("Part")
		explosion.Name = "Explosion"
		explosion.CFrame = CFrame.new(event.position)
		explosion.Size = part.Size
		explosion.Transparency = 0.55
		explosion.Anchored = true
		explosion.CanCollide = false
		explosion.BrickColor = BrickColor.Red()
		explosion.Material = Enum.Material.Neon
		explosion.Shape = Enum.PartType.Ball
		explosion.CastShadow = false
		explosion.Parent = workspace

		local newId = params.Crossbow:SpawnBind(explosion, components.Lifetime({
			duration = 0.5;
			timestamp = params.currentFrame;
		}))

		if world:contains(event.spawnerId) then
			local skin = world:get(event.spawnerId, components.Skin)
			if skin then
				local projectile = world:get(event.spawnerId, components.Projectile)
				if projectile and skin.explosionDecorator then
					skin.explosionDecorator(explosion, projectile.character, newId)
				else
					skin.explosionDecorator(explosion, nil, newId)
				end
			end
		end
	end
end

return {
    realm = "client";
    system = showExplosions;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}