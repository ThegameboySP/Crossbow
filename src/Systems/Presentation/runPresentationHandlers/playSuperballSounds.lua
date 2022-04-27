local function playSuperballSounds(world, components, params)
    for _, id in params.events:iterate("ricocheted") do
        local superball = world:get(id, components.Superball)
        if superball == nil then
            continue
        end

        local spawnerId = world:get(id, components.Projectile).spawnerId

        if params.soundPlayer:getActiveSoundCount(spawnerId) == 0 then
            params.soundPlayer:queueSound(
                params.Settings.Superball.bounceSound:Get(),
                nil,
                world:get(id, components.Part).part.Position,
                2
            )
        end
    end
end

return playSuperballSounds