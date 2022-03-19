local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)

local function throttleSounds(_, _, params)
    local lastPlayed = useHookStorage()
    local throttledSounds = params.Settings.ThrottledSounds

    for _, soundValue, discriminator, pos in params.events:iterate("queueSound") do
        local limit = throttledSounds[soundValue]
        if not limit then
            params.events:fire("playSound", soundValue, pos)
            continue
        end

        discriminator = discriminator or soundValue
        lastPlayed[discriminator] = lastPlayed[discriminator] or {}

        local timestamp = lastPlayed[discriminator][soundValue]
        if timestamp == nil then
            timestamp = 0
            lastPlayed[discriminator][soundValue] = timestamp
        end

        if params.currentFrame - timestamp > limit then
            params.events:fire("playSound", soundValue, pos, discriminator)
        end
    end

    for _, soundValue, _, discriminator in params.events:iterate("playSound") do
        if discriminator then
            lastPlayed[discriminator] = lastPlayed[discriminator] or {}
            lastPlayed[discriminator][soundValue] = params.currentFrame
        end
    end

    for _, id in params.events:iterate("queueRemove") do
        lastPlayed[id] = nil
    end
end

return {
    realm = "client";
    system = throttleSounds;
    event = "PostSimulation";
    priority = Priorities.Presentation + 8;
}