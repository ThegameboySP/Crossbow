local Priorities = require(script.Parent.Parent.Priorities)
local useCoroutine = require(script.Parent.Parent.Parent.Shared.useCoroutine)

local function tickBomb(explodeCountdown)
    local interval = explodeCountdown.startingInterval
    local multiplier = explodeCountdown.multiplier
    local tickColors = explodeCountdown.tickColors
    
    local tickIndex = 1
    while interval > 0.1 do
        coroutine.yield(interval, tickIndex)
        interval *= multiplier
        tickIndex = tickIndex % #tickColors + 1
    end
end

local function presentationHandler(world, components, params)
    for _, id, color in params.events:iterate("explodeCountdown-ticked") do
        local part = world:get(id, components.Part)
        if part then
            part.part.Color = color
            params.events:fire("queueSound", params.Settings.Sounds.bombTick, id, part.part.Position)
        end
    end
end

local function updateExplodeCountdown(world, components, params)
    for id, explodeCountdown, part in world:query(components.ExplodeCountdown, components.Part) do
        local isRunning, colorIndex = useCoroutine(tickBomb, id, params.currentFrame, explodeCountdown)
        if colorIndex then
            params.events:fire("queuePresentation", presentationHandler, world, components, params)
            params.events:fire("explodeCountdown-ticked", id, explodeCountdown.tickColors[colorIndex])
        end
        
        if not isRunning then
            params.events:fire("queueRemove", id)
            params.events:fire("explosion", part.part.Position, explodeCountdown.radius, 100, world:get(id, components.Owned) ~= nil, id)
        end
    end
end

return {
    system = updateExplodeCountdown;
	event = "PreSimulation";
	priority = Priorities.Projectiles;
}