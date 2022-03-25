local Debris = game:GetService("Debris")

local Priorities = require(script.Parent.Parent.Priorities)
local updateToolActions = require(script.Parent.updateToolActions)

local LUNGE_TIME = 0.8
local SLASH_TIME = 0.2

local function makeAnimationSetter(name)
    return function(world, components, params, id)
        local instance, part = world:get(id, components.Instance, components.Part)
        if instance and part then
            local tool = instance.instance

            local toolAnim = Instance.new("StringValue")
            toolAnim.Name = "toolanim"
            toolAnim.Value = name
            toolAnim.Parent = tool

            if name == "Slash" then
                params.events:fire("playSound", params.Settings.Sounds.swordSlash, part.part.Position)
            elseif name == "Lunge" then
                params.events:fire("playSound", params.Settings.Sounds.swordLunge, part.part.Position)

                tool.GripForward = Vector3.new(0, 0, 1)
                tool.GripRight = Vector3.new(0, -1, 0)
                tool.GripUp = Vector3.new(-1, 0, 0)

                task.delay(LUNGE_TIME, function()
                    tool.GripForward = Vector3.new(-1, 0, 0)
                    tool.GripRight = Vector3.new(0, 1, 0)
                    tool.GripUp = Vector3.new(0, 0, 1)
                end)
            end
        end
    end
end

local lungeAnimation = makeAnimationSetter("Lunge")
local slashAnimation = makeAnimationSetter("Slash")

local function updateSwords(world, components, params)
    local query =
        if params.Crossbow.IsServer then world:query(components.SwordTool, components.Tool)
        else world:query(components.SwordTool, components.Tool, components.Owned)
    
    for id, sword, tool in query do
        if sword.state == "Idle" or tool.reloadTimeLeft > 0 then
            continue
        end

        world:insert(id, sword:patch({
            state = "Idle";
        }))

        world:insert(id, world:get(id, components.Damage):patch({
            damage = sword.idleDamage;
        }))
    end

    for _, id, state in params.events:iterate("tool-activated-fire") do
        local sword, tool, damage = world:get(id, components.SwordTool, components.Tool, components.Damage)
        if sword == nil or sword.state ~= "Idle" or state == "Idle" then
            continue
        end

        world:insert(id, sword:patch({
            state = state;
        }), damage:patch({
            damage = state == "Slashing" and sword.slashDamage or sword.lungeDamage;
        }))

        if state == "Lunging" then
            local head = tool:getHead()
            local hum = tool:getHumanoid()

            if
                head
                and hum.FloorMaterial == Enum.Material.Air
                and sword.floatAmount > 0
            then
                local lungeForce = Instance.new("BodyVelocity")
                lungeForce.Velocity = Vector3.new(0, sword.floatHeight, 0)
                lungeForce.MaxForce = Vector3.new(0, sword.floatAmount, 0)
                lungeForce.Name = "LungeForce"
                lungeForce.Parent = head

                Debris:AddItem(lungeForce, 0.5)
            end

            world:insert(id, tool:patch({
                reloadTimeLeft = LUNGE_TIME;
            }))
        end
    end

    for id, swordRecord in world:queryChanged(components.SwordTool) do
        if swordRecord.new then
            local state = swordRecord.new.state

            if swordRecord.old == nil or state ~= swordRecord.old.state then
                if state == "Lunging" then
                    params.events:fire("queuePresentation", lungeAnimation, world, components, params, id)
                elseif state == "Slashing" then
                    params.events:fire("queuePresentation", slashAnimation, world, components, params, id)
                end
            end
        end
    end
end

return {
    system = updateSwords;
    event = "PreSimulation";
    after = { updateToolActions };
    priority = Priorities.Tools;
}