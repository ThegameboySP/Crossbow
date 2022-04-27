local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)

local function generateCollisions(world, components, params)
    local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()
    local connections = useHookStorage()

    table.clear(params.hitQueue)

    for id, record in world:queryChanged(components.Projectile) do
        if record.new and not connections[id] then
            local part = world:get(id, components.Part)

            connections[id] = getTouchedSignal(part.part):Connect(function(hit)
                local queue = params.hitQueue[id]

                if queue == nil then
                    queue = {}
                    params.hitQueue[id] = queue
                end

                table.insert(queue, hit)
            end)
        elseif not record.new and connections[id] then
            connections[id]:Disconnect()
            connections[id] = nil
        end
    end
end

return {
    system = generateCollisions;
    event = "PreSimulation";
    priority = Priorities.CoreAfter + 9;
}