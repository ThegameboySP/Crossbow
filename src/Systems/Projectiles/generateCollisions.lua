local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)

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
            if record.new and not state.connections[id] then
                local part = world:get(id, components.Part)

                state.connections[id] = getTouchedSignal(part.part):Connect(function(hit)
                    local queue = params.hitQueue[id]

                    if queue == nil then
                        queue = {}
                        params.hitQueue[id] = queue
                    end

                    table.insert(queue, hit)
                end)
                
            elseif not record.new and state.connections[id] then
                state.connections[id]:Disconnect()
                state.connections[id] = nil
            end
        end
    end
end

return {
    system = generateCollisions;
    event = "PreSimulation";
    priority = Priorities.CoreAfter + 9;
}