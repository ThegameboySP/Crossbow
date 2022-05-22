local Priorities = require(script.Parent.Parent.Priorities)

local function handlesTransparentOnReload(world, components, params)
    for _id, part, tool in world:query(components.Part, components.Tool, components.Owned):without(components.SwordTool) do
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