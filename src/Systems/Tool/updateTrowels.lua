local updateToolActions = require(script.Parent.updateToolActions)
local Priorities = require(script.Parent.Parent.Priorities)

local Callbacks = require(script.Parent.Parent.Parent.Utilities.Callbacks)
local useCoroutine = require(script.Parent.Parent.Parent.Shared.useCoroutine)

local function setupTrowel(sleep, world, components, params, id)
    local trowelWall = world:get(id, components.TrowelWall)
    local cframe = world:get(id, components.Transform).cframe

    local trowelTool = world:get(trowelWall.spawnerId, components.TrowelTool)
    local tool = world:get(trowelWall.spawnerId, components.Tool)

    return Callbacks.buildTrowel(
        sleep,
        params.Crossbow.Settings.Callbacks[trowelTool.shouldWeld],
        world:get(id, components.Instance).instance,
        trowelTool:getLookDirection(tool:getDirection(cframe.Position, "Head")),
        trowelTool,
        trowelWall.normal,
        trowelWall.part,
        cframe.Position
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

        local model = Instance.new("Model")
        model.Name = "TrowelWall"
        model.Parent = workspace

        params.Crossbow:SpawnBind(
            model,
            components.Owned(),
            params.Packs[trowelTool.pack](id, pos, part, normal, dir)
        )

        if trowelTool.buildSound then
            params.soundPlayer:queueSound(trowelTool.buildSound, id, pos)
        end
    end

    for id in world:query(components.TrowelBuilding, components.TrowelWall) do
        local isRunning = useCoroutine(setupTrowel, id, params.deltaTime, world, components, params, id)

        if not isRunning then
            world:remove(id, components.TrowelBuilding)

            world:insert(id, components.Lifetime({
                duration = params.Settings.TrowelTool.lifetime:Get();
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