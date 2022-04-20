local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function disconnectTouched(state, id)
    if state.connections[id] then
        state.connections[id]:Disconnect()
        state.connections[id] = nil
        table.clear(state.touchedQueue[id])
    end
end

local function connectTouched(state, id, part)
	state.touchedQueue[id] = state.touchedQueue[id] or {}
	state.connections[id] = part.Touched:Connect(function(hit)
		table.insert(state.touchedQueue[id], hit)
	end)
end

local function initState(state)
    state.connections = {};
    state.touchedQueue = {};
    state.ids = {};
end

local function updateSuperballs(world, components, params)
    local hitFilter = params.Settings.Superball.hitFilter:Get()
    -- local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()

    local state = useHookStorage(nil, initState)

    for id, partRecord in world:queryChanged(components.Part) do
        if partRecord.new and world:get(id, components.Superball, components.Owned) then
            state.ids[id] = true
        else
            state.ids[id] = nil
        end

        disconnectTouched(state, id)
    end

    for id, superballRecord in world:queryChanged(components.Superball) do
        if superballRecord.new and world:get(id, components.Part, components.Owned) then
            state.ids[id] = true
        elseif not superballRecord.new then
            state.ids[id] = nil
            
            disconnectTouched(state, id)
		end
    end

    for id in pairs(state.ids) do
        local part, superball, projectile = world:get(id, components.Part, components.Superball, components.Projectile)
        if not state.connections[id] then
            connectTouched(state, id, part.part)
            continue
        end

        local touchedQueue = state.touchedQueue[id]
        for i, hit in ipairs(touchedQueue) do
            touchedQueue[i] = nil

            if not hitFilter(hit) then
                continue
            end
            
            if params.currentFrame - (superball.lastHitTimestamp or 0) >= superball.bouncePauseTime then
                local bounces = (superball.bounces or 0) + 1
                params.events:fire("superballBounce", id)
                
                if superball.bounceSound then
                    params.events:fire("queueSound", superball.bounceSound, projectile.spawnerId, part.part.Position)
                end

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

return {
    event = "PostSimulation";
    system = updateSuperballs;
    priority = Priorities.Projectiles;
}