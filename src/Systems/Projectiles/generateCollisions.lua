local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Crossbow_Projectile"

local function generateCollisions(world, components, params)
    local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()
    local state = useHookStorage()
    if not state.componentsToTrack then
        state.componentsToTrack = {components.Damage, components.Ricochets, components.ExplodeOnTouch}
        state.connections = {}
    end

    table.clear(params.hitQueue)

    for _, component in ipairs(state.componentsToTrack) do
        for id, record in world:queryChanged(component) do
            if not record.new or not world:contains(id) or not world:get(id, components.Part) then
                if state.connections[id] then
                    state.connections[id]:Disconnect()
                    state.connections[id] = nil
                end

                continue
            end

            local part = world:get(id, components.Part)

            -- .Touched seems to ignore characters some of the time with explosions.
            if world:get(id, components.Explosion) then
                params.hitQueue[id] = workspace:GetPartsInPart(part.part, overlapParams)
            elseif not state.connections[id] then
                state.connections[id] = getTouchedSignal(part.part):Connect(function(hit)
                    local queue = params.hitQueue[id]

                    if queue == nil then
                        queue = {}
                        params.hitQueue[id] = queue
                    end

                    table.insert(queue, hit)
                end) 
            end
        end
    end
end

return {
    system = generateCollisions;
    event = "PreSimulation";
    priority = Priorities.CoreAfter + 9;
}