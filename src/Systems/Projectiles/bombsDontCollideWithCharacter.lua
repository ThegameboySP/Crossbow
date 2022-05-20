local component = require(script.Parent.Parent.Parent.Parent.Matter).component
local Priorities = require(script.Parent.Parent.Priorities)

local NoCollision = component()
local Processed = component()

local xz = Vector3.new(1, 0, 1)

local function bombsDontCollideWithCharacter(world, components)
    for id, part, projectile in world:query(components.Part, components.Projectile, components.Bomb, components.Owned):without(Processed) do
        local bombPart = part.part
        local noCollision = world:get(id, NoCollision)

        if noCollision then
            if (bombPart.AssemblyLinearVelocity * xz).Magnitude > 10 then
                for _, constraint in pairs(noCollision.constraints) do
                    constraint.Parent = nil
                end

                world:insert(id, Processed())
            end
        else
            if (bombPart.AssemblyLinearVelocity * xz).Magnitude <= 10 then
                local constraints = {}
                world:insert(id, NoCollision({
                    constraints = constraints;
                }))

                local character = projectile.character

                if character then
                    for _, descendant in pairs(character:GetDescendants()) do
                        -- Ignore Head so bomb throws are still possible.
                        if descendant:IsA("BasePart") and descendant.Name ~= "Head" then
                            local constraint = Instance.new("NoCollisionConstraint")
                            constraint.Part0 = bombPart
                            constraint.Part1 = descendant
                            constraint.Parent = bombPart

                            table.insert(constraints, constraint)
                        end
                    end
                end
            end
        end
    end
end

return {
    system = bombsDontCollideWithCharacter;
    event = "PreSimulation";
    priority = Priorities.Projectiles;
}