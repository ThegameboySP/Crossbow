local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)

local function queueSuperballSounds(world, components, params)
    local Sounds = params.Settings.Sounds
    local lastBounced = useHookStorage()

    for _, id in params.events:iterate("superballBounce") do
        if params.currentFrame - (lastBounced[id] or 0) < 1 then
            continue
        end
    
        lastBounced[id] = params.currentFrame
        params.events:fire("playSound", Sounds.superballBounce, world:get(id, components.Part).part.Position)
    end

    for _, id in params.events:iterate("queueRemove") do
        lastBounced[id] = nil
    end
end

return {
    realm = "client";
    event = "PostSimulation";
    system = queueSuperballSounds;
    priority = Priorities.Presentation;
}