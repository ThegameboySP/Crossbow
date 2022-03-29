local Priorities = require(script.Parent.Parent.Priorities)
local useCoroutine = require(script.Parent.Parent.Parent.Shared.useCoroutine)

local function tickBomb(sleep, explodeCountdown)
    local interval = explodeCountdown.startingInterval
    local multiplier = explodeCountdown.multiplier
    local tickColors = explodeCountdown.tickColors
    
    local tickIndex = 1
    while interval > 0.1 do
        sleep(interval, tickIndex)
        interval *= multiplier
        tickIndex = tickIndex % #tickColors + 1
    end
end

local function presentationHandler(world, components, params)
    for _, id, color in params.events:iterate("explodeCountdown-ticked") do
        local part, explodeCountdown = world:get(id, components.Part, components.ExplodeCountdown)
        if part then
            part.part.Color = color

            if explodeCountdown.tickSound then
                params.events:fire("queueSound", explodeCountdown.tickSound, id, part.part.Position)
            end
        end
    end
end

local function updateExplodeCountdown(world, components, params)
    for id, explodeCountdown, part in world:query(components.ExplodeCountdown, components.Part) do
        local isRunning, colorIndex = useCoroutine(tickBomb, id, explodeCountdown)
        if colorIndex then
            params.events:fire("queuePresentation", presentationHandler, world, components, params)
            params.events:fire("explodeCountdown-ticked", id, explodeCountdown.tickColors[colorIndex])
        end
        
        if not isRunning then
            params.events:fire("queueRemove", id)
            params.events:fire("explosion", part.part.Position, explodeCountdown.radius, 100, world:get(id, components.Owned) ~= nil, id, explodeCountdown.explodeSound)
        end
    end
end

return {
    system = updateExplodeCountdown;
	event = "PreSimulation";
	priority = Priorities.Projectiles;
}