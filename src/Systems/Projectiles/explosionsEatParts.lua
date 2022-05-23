local CollectionService = game:GetService("CollectionService")

local Priorities = require(script.Parent.Parent.Priorities)
local General = require(script.Parent.Parent.Parent.Utilities.General)

local function explosionsEatParts(world, components, params)
    local maxMass = params.Settings.ExplosionsEatParts.maxMass:Get()

    for id in world:query(components.Part, components.Explosion) do
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
}