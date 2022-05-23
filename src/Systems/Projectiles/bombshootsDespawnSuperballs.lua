local PhysicsService = game:GetService("PhysicsService")

local component = require(script.Parent.Parent.Parent.Parent.Matter).component
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local Processed = component()

local function bombshootsDespawnSuperballs(world, params)
    for id in world:query(Components.Part, Components.Superball, Components.Owned):without(Processed) do
        local queue = params.hitQueue[id]
        if queue == nil then
            continue
        end

        for _, hit in pairs(queue) do
            local bombId, projectile = params.Crossbow:GetProjectile(hit)

            if projectile and projectile.componentName == "Bomb" and world:get(bombId, Components.Owned) then
                world:remove(id, Components.Damage)
                world:insert(id, Processed())

                PhysicsService:SetPartCollisionGroup(world:get(id, Components.Part).part, "Crossbow_Visual")

                params.events:fire("bombshoot", hit.Position, id, bombId)
                
                world:insert(id, Components.Lifetime({
                    duration = 1;
                    timestamp = params.currentFrame;
                }))

                break
            end
        end
    end
end

return {
    system = bombshootsDespawnSuperballs;
    event = "PostSimulation";
    priority = Priorities.Projectiles;
}