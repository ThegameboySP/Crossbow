local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local TRACKING_COMPONENTS = {
    Components.Damage,
    Components.Ricochets,
    Components.ExplodeOnTouch,
    Components.Part
}

local function generateCollisions(world, params)
    local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()
    local connections = useHookStorage()

    table.clear(params.hitQueue)

    for _, component in pairs(TRACKING_COMPONENTS) do
        for id, record in world:queryChanged(component) do
            if record.new and connections[id] then
                continue
            end

            if not world:contains(id) or world:get(id, Components.Explosion) then
                if connections[id] then
                    connections[id]:Disconnect()
                    connections[id] = nil
                end

                continue
            end

            local hasComponent = false
            
            for _, metatable in pairs(TRACKING_COMPONENTS) do
                hasComponent = not not world:get(id, metatable)

                if hasComponent then
                    break
                end
            end

            if not hasComponent then
                if connections[id] then
                    connections[id]:Disconnect()
                    connections[id] = nil
                end

                continue
            end

            local part = world:get(id, Components.Part)

            if not connections[id] then
                connections[id] = getTouchedSignal(part.part):Connect(function(hit)
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