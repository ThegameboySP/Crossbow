local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function handlesTransparentOnReload(world, params)
    for id, toolRecord in world:queryChanged(Components.Tool) do
        if toolRecord.new and toolRecord.new.isEquipped and toolRecord.old and not toolRecord.old.isEquipped then
            local part = world:get(id, Components.Part)

            if part then
                local timeLeft = toolRecord.new.nextReloadTimestamp - params.currentFrame
                part.part.Transparency = (timeLeft > 0) and 0.4 or 0
            end
        end
    end
end

return {
    realm = "client";
    system = handlesTransparentOnReload;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}