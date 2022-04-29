local useHookStorage = require(script.Parent.Parent.Parent.Parent.Shared.useHookStorage)

local function playSuperballSounds(world, components, params)
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
        
        local superball = world:get(id, components.Superball)
        if superball == nil then
            continue
        end

        local spawnerId = world:get(id, components.Projectile).spawnerId

        if params.soundPlayer:getActiveSoundCount(spawnerId) == 0 then
            if params.soundPlayer:queueSound(
                params.Settings.Superball.bounceSound:Get(),
                nil,
                world:get(id, components.Part).part.Position,
                2
            ) then
                lastPlayed[id] = currentFrame
            end
        end
    end
end

return playSuperballSounds