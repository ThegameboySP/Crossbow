local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function updateSuperballs(world, params)
    local callbacks = params.Settings.Callbacks
    local hitQueue = params.hitQueue
    local currentFrame = params.currentFrame

    for id, ricochets in world:query(Components.Ricochets, Components.Owned) do
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
                
                if (ricochets.ricochets + 1) >= ricochets.maxRicochets then
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
    event = "PostSimulation";
    system = updateSuperballs;
    priority = Priorities.Projectiles + 9;
}