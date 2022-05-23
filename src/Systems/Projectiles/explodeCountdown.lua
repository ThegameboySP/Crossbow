local Priorities = require(script.Parent.Parent.Priorities)
local useCoroutine = require(script.Parent.Parent.Parent.Shared.useCoroutine)
local Components = require(script.Parent.Parent.Parent.Components)

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

local function presentationHandler(world, params)
    for _, id, color in params.events:iterate("explodeCountdown-ticked") do
        local part, explodeCountdown = world:get(id, Components.Part, Components.ExplodeCountdown)
        if part then
            part.part.Color = color

            if explodeCountdown.tickSound then
                params.soundPlayer:queueSound(explodeCountdown.tickSound, nil, part.part.Position, 10)
            end
        end
    end
end

local function updateExplodeCountdown(world, params)
    for id, explodeCountdown, part in world:query(Components.ExplodeCountdown, Components.Part) do
        local lagCompensation = world:get(id, Components.LagCompensation)
        local dt
        if lagCompensation then
            dt = params.currentFrame - lagCompensation.timestamp
        else
            dt = params.deltaTime
        end

        local isRunning, args = useCoroutine(tickBomb, id, dt, explodeCountdown)
        if args[1] then
            params.events:fire("queuePresentation", presentationHandler, world, params)
            params.events:fire("explodeCountdown-ticked", id, explodeCountdown.tickColors[args[#args][1]])
        end
        
        if not isRunning then
            params.events:fire("queueRemove", id)
            params.events:fire("explosion", part.part.Position, explodeCountdown.radius, 100, world:get(id, Components.Owned) ~= nil, id, explodeCountdown.explodeSound)
        end
    end
end

return {
    system = updateExplodeCountdown;
	event = "PreSimulation";
	priority = Priorities.Projectiles + 1;
}