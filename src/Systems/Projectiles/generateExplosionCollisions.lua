local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)
local applyExplosion = require(script.Parent.applyExplosion)

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Crossbow_Projectile"

local function generateExplosionCollisions(world, params)
    -- .Touched seems to be unreliable with explosions.
    for id, part in world:query(Components.Part, Components.Explosion) do
        params.hitQueue[id] = workspace:GetPartsInPart(part.part, overlapParams)
    end
end

return {
    system = generateExplosionCollisions;
    event = "PostSimulation";
    priority = Priorities.Projectiles;
    after = { applyExplosion };
}