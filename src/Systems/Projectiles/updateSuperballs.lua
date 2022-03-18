local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local function updateSuperballs(world, components, params)
    local hitFilter = params.Settings.Superball.hitFilter:Get()
    local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()

    for id, part, superball in world:query(components.Part, components.Superball, components.Local) do
        for _, hit in Matter.useEvent(part.part, getTouchedSignal(part.part)) do
            if not hitFilter(hit) then
                continue
            end
            
            if world:get(id, components.Local) then
                if params.currentFrame - (superball.lastHitTimestamp or 0) >= superball.bouncePauseTime then
                    local bounces = (superball.bounces or 0) + 1
                    params.events:fire("superballBounce", id)

                    if bounces > superball.maxBounces then
                        params.events:fire("queueRemove", id)
                    else
                        world:insert(id, superball:patch({
                            bounces = (superball.bounces or 0) + 1;
                            lastHitTimestamp = params.currentFrame;
                        }))
                    end
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