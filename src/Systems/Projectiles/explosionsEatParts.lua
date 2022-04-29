local CollectionService = game:GetService("CollectionService")

local Priorities = require(script.Parent.Parent.Priorities)
local General = require(script.Parent.Parent.Parent.Utilities.General)

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Crossbow_Projectile"

local function explosionsEatParts(world, components, params)
    local maxMass = params.Settings.ExplosionsEatParts.maxMass:Get()

    for _id, part in world:query(components.Part, components.Explosion) do
        for _, hit in pairs(workspace:GetPartsInPart(part.part, overlapParams)) do
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