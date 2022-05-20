local component = require(script.Parent.Parent.Parent.Parent.Parent.Matter).component
local OriginalColor = component()

local WHITE = Color3.fromRGB(255, 255, 255)

local function showSuperballDamageColor(world, components)
    for id, part, ricochets in world:query(components.Part, components.Ricochets):without(OriginalColor) do
        if ricochets.maxRicochets > 1 then
            world:insert(id, OriginalColor({
                color = part.part.Color;
            }))
        end
    end

    for _id, ricochetsRecord, part, originalColor in world:queryChanged(components.Ricochets, components.Part, OriginalColor) do
        local ricochets = ricochetsRecord.new
        
        if ricochets then
            part.part.Color = originalColor.color:lerp(WHITE, ricochets.ricochets / ricochets.maxRicochets)
        end
    end
end

return showSuperballDamageColor