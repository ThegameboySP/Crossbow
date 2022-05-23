local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function playSuperballSounds(world, params)
    local currentFrame = params.currentFrame

    local lastPlayed = useHookStorage()
    for id, timestamp in pairs(lastPlayed) do
        if (currentFrame - timestamp) > 2 then
            lastPlayed[id] = nil
        end
    end

    for _, id in params.events:iterate("ricocheted") do
        if lastPlayed[id] then
            continue
        end
        
        local superball = world:get(id, Components.Superball)
        if superball == nil then
            continue
        end

        local spawnerId = world:get(id, Components.Projectile).spawnerId

        if params.soundPlayer:getActiveSoundCount(spawnerId) == 0 then
            if params.soundPlayer:queueSound(
                params.Settings.Superball.bounceSound:Get(),
                nil,
                world:get(id, Components.Part).part.Position,
                2
            ) then
                lastPlayed[id] = currentFrame
            end
        end
    end
end

return {
    realm = "client";
    system = playSuperballSounds;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}