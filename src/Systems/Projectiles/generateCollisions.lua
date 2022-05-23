local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Crossbow_Projectile"

local TRACKING_COMPONENTS = {
    Components.Damage,
    Components.Ricochets,
    Components.ExplodeOnTouch
}

local function generateCollisions(world, params)
    local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()
    local connections = useHookStorage()

    table.clear(params.hitQueue)

    for _, component in pairs(TRACKING_COMPONENTS) do
        for id, record in world:queryChanged(component) do
            if not record.new or not world:contains(id) or not world:get(id, Components.Part) then
                if connections[id] then
                    connections[id]:Disconnect()
                    connections[id] = nil
                end

                continue
            end

            local part = world:get(id, Components.Part)

            -- .Touched seems to ignore characters some of the time with explosions.
            if world:get(id, Components.Explosion) then
                params.hitQueue[id] = workspace:GetPartsInPart(part.part, overlapParams)
            elseif not connections[id] then
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