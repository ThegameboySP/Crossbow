local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function showExplosions(world, components, params)
	local displayingIds = useHookStorage()

	for id, record in world:queryChanged(components.Explosion) do
		if not record.new then
			local part = displayingIds[id]
			task.delay(0.5, part.Destroy, part)
			displayingIds[id] = nil
		end
	end

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

		displayingIds[event.newId] = explosion
	end
end

return {
    realm = "client";
    system = showExplosions;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}