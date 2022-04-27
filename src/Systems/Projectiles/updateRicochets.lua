local Priorities = require(script.Parent.Parent.Priorities)

local applyDamage = require(script.Parent.applyDamage)

local function updateSuperballs(world, components, params)
    local callbacks = params.Settings.Callbacks
    local hitQueue = params.hitQueue
    local currentFrame = params.currentFrame

    for id, ricochets in world:query(components.Ricochets, components.Owned) do
        local queue = hitQueue[id]
        if queue == nil then
            continue
        end

        local hitFilter = callbacks[ricochets.filter]

        for _, hit in ipairs(queue) do
            if not hitFilter(hit) then
                continue
            end
            
            if (currentFrame - ricochets.timestamp) >= ricochets.debounce then
                params.events:fire("ricocheted", id)
                
                if ricochets.ricochetSound then
                    params.events:fire(
                        "queueSound",
                        ricochets.ricochetSound,
                        world:get(id, components.Projectile).spawnerId,
                        world:get(id, components.Part).part.Position,
                        1
                    )
                end

                if (ricochets.ricochets + 1) > ricochets.maxRicochets then
                    params.events:fire("queueRemove", id)
                else
                    world:insert(id, ricochets:patch({
                        ricochets = ricochets.ricochets + 1;
                        timestamp = currentFrame;
                    }))
                end
            end
        end
    end
end

return {
    event = "PreSimulation";
    system = updateSuperballs;
    priority = Priorities.Projectiles + 9;
    after = { applyDamage };
}