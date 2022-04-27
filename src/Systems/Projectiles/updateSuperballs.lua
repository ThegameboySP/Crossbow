local Priorities = require(script.Parent.Parent.Priorities)

local function updateSuperballs(world, components, params)
    local hitFilter = params.Settings.Callbacks[params.Settings.Superball.ricochetFilter:Get()]
    local currentFrame = params.currentFrame

    for id, superball, part in world:query(components.Superball, components.Part, components.Owned) do
        local queue = params.hitQueue[id]
        if queue == nil then
            continue
        end

        for _, hit in ipairs(queue) do
            if not hitFilter(hit) then
                continue
            end
            
            if currentFrame - (superball.lastHitTimestamp or 0) >= superball.bouncePauseTime then
                local bounces = (superball.bounces or 0) + 1
                params.events:fire("superballBounce", id)
                
                if superball.bounceSound then
                    params.events:fire("queueSound", superball.bounceSound, world:get(id, components.Projectile).spawnerId, part.part.Position)
                end

                if bounces > superball.maxBounces then
                    params.events:fire("queueRemove", id)
                else
                    world:insert(id, superball:patch({
                        bounces = (superball.bounces or 0) + 1;
                        lastHitTimestamp = currentFrame;
                    }))
                end
            end
        end
    end
end

return {
    event = "PostSimulation";
    system = updateSuperballs;
    priority = Priorities.Projectiles;
}