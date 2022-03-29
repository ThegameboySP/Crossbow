local useCoroutine = require(script.Parent.Parent.Parent.Shared.useCoroutine)
local updateToolActions = require(script.Parent.updateToolActions)
local Priorities = require(script.Parent.Parent.Priorities)

local Callbacks = require(script.Parent.Parent.Parent.Utilities.Callbacks)

local function buildTrowelTop(sleep, world, components, params, trowelBuilding, transform)
    local spawnerId = trowelBuilding.spawnerId
    local trowelTool = world:get(spawnerId, components.TrowelTool)
    local tool = world:get(spawnerId, components.Tool)

    return Callbacks.buildTrowel(
        sleep,
        params.Crossbow.Settings.Callbacks,
        workspace,
        trowelTool:getLookDirection(tool:getDirection(transform.cframe.Position, "Head")),
        trowelTool,
        trowelBuilding.normal,
        trowelBuilding.part,
        transform.cframe.Position
    )
end

local function updateTrowels(world, components, params)
    for _, id, pos, part, normal in params.events:iterate("tool-activated-fire") do
        local trowelTool = world:get(id, components.TrowelTool)
        if not trowelTool then
            continue
        end

        local tool = world:get(id, components.Tool)
        local dir = tool:getDirection(pos, "Head")

        world:spawn(components.TrowelBuilding({
            normal = normal;
            part = part;
            spawnerId = id;
        }), components.Transform({
            cframe = CFrame.lookAt(pos, pos - dir);
        }), components.Owned())

        if trowelTool.buildSound then
            params.events:fire("playSound", trowelTool.buildSound, pos, id)
        end
    end

    for id, trowelBuilding, transform in world:query(components.TrowelBuilding, components.Transform, components.Owned):without(components.TrowelWall) do
        local isRunning, model = useCoroutine(buildTrowelTop, id, world, components, params, trowelBuilding, transform)

        if not isRunning then
            params.Crossbow:InsertBind(model, id, components.TrowelWall(), components.Lifetime({
                duration = 10;
                timestamp = params.currentFrame;
            }))
        end
    end
end

return {
    system = updateTrowels;
    event = "PreSimulation";
    after = { updateToolActions };
    priority = Priorities.Tools;
}