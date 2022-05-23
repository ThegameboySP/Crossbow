local component = require(script.Parent.Parent.Parent.Parent.Matter).component
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local OriginalColor = component()
local WHITE = Color3.fromRGB(255, 255, 255)

local function showRicochetColor(world)
    for id, part, ricochets in world:query(Components.Part, Components.Ricochets):without(OriginalColor) do
        if ricochets.maxRicochets > 1 then
            world:insert(id, OriginalColor({
                color = part.part.Color;
            }))
        end
    end

    for _id, ricochetsRecord, part, originalColor in world:queryChanged(Components.Ricochets, Components.Part, OriginalColor) do
        local ricochets = ricochetsRecord.new
        
        if ricochets then
            part.part.Color = originalColor.color:lerp(WHITE, ricochets.ricochets / ricochets.maxRicochets)
        end
    end
end

return {
    realm = "client";
    system = showRicochetColor;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}