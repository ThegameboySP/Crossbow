local CollectionService = game:GetService("CollectionService")

local Priorities = require(script.Parent.Parent.Priorities)
local generateExplosionCollisions = require(script.Parent.generateExplosionCollisions)
local General = require(script.Parent.Parent.Parent.Utilities.General)
local Components = require(script.Parent.Parent.Parent.Components)

local function explosionsEatParts(world, params)
    local maxMass = params.Settings.ExplosionsEatParts.maxMass:Get()

    for id in world:query(Components.Part, Components.Explosion) do
        local queue = params.hitQueue[id]
        if queue == nil then
            continue
        end

        for _, hit in ipairs(queue) do
            if
                not hit.Anchored
                and not CollectionService:HasTag(hit, "BB_NonExplodable")
                and not CollectionService:HasTag(hit, "Crossbow_Projectile")
                and hit:GetMass() <= maxMass
                and not General.getCharacter(hit)
            then
                hit.Parent = nil
            end
        end
    end
end

return {
    system = explosionsEatParts;
    event = "PostSimulation";
    priority = Priorities.Projectiles;
    after = { generateExplosionCollisions };
}