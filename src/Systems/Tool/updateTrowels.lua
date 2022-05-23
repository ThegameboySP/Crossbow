local updateToolActions = require(script.Parent.updateToolActions)
local Priorities = require(script.Parent.Parent.Priorities)

local useCoroutine = require(script.Parent.Parent.Parent.Shared.useCoroutine)
local Components = require(script.Parent.Parent.Parent.Components)

local function setupTrowel(sleep, world, params, id)
    local trowelWall = world:get(id, Components.TrowelWall)
    local cframe = world:get(id, Components.Transform).cframe

    local trowelTool = world:get(trowelWall.spawnerId, Components.TrowelTool)
    local tool = world:get(trowelWall.spawnerId, Components.Tool)

    return Components.TrowelTool.buildTrowel(
        sleep,
        params.Crossbow.Settings.Callbacks[trowelTool.shouldWeld],
        world:get(id, Components.Instance).instance,
        trowelTool:getLookDirection(tool:getDirection(cframe.Position, "Head")),
        trowelTool,
        trowelWall.normal,
        trowelWall.part,
        cframe.Position
    )
end

local function updateTrowels(world, params)
    for _, id, pos, part, normal in params.events:iterate("tool-activated-fire") do
        local trowelTool = world:get(id, Components.TrowelTool)
        if not trowelTool then
            continue
        end

        local tool = world:get(id, Components.Tool)
        local dir = tool:getDirection(pos, "Head")

        local model = Instance.new("Model")
        model.Name = "TrowelWall"
        model.Parent = workspace

        params.Crossbow:SpawnBind(
            model,
            Components.Owned(),
            params.Packs[trowelTool.pack](id, pos, part, normal, dir)
        )

        if trowelTool.buildSound then
            params.soundPlayer:queueSound(trowelTool.buildSound, id, pos)
        end
    end

    for id in world:query(Components.TrowelBuilding, Components.TrowelWall) do
        local isRunning = useCoroutine(setupTrowel, id, params.deltaTime, world, params, id)

        if not isRunning then
            world:remove(id, Components.TrowelBuilding)

            world:insert(id, Components.Lifetime({
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