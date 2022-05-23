local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function handlesTransparentOnReload(world, params)
    for _id, part, tool in world:query(Components.Part, Components.Tool, Components.Owned):without(Components.SwordTool) do
        if tool.isEquipped then
            local timeLeft = tool.nextReloadTimestamp - params.currentFrame
            part.part.Transparency = (timeLeft > 0) and 0.4 or 0
        end
    end
end

return {
    realm = "client";
    system = handlesTransparentOnReload;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}