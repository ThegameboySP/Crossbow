local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local Priorities = require(script.Parent.Parent.Priorities)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local useEvent = require(script.Parent.Parent.Parent.Parent.Matter).useEvent

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Blacklist

local function superballFireDoubleJumps(world, components, params)
    local storage = useHookStorage(nil, function(state)
        state.jumpedCharacter = nil
        state.lastJumpRequest = 0
    end)

    if storage.jumpedCharacter then
        for _, part in pairs({storage.jumpedCharacter["Left Leg"], storage.jumpedCharacter["Right Leg"]}) do
            local hitPart
            for _, hit in pairs(workspace:GetPartsInPart(part, overlapParams)) do
                if not CollectionService:HasTag(hit, "Crossbow_Projectile") then
                    hitPart = hit
                    break
                end
            end

            if hitPart then
                storage.jumpedCharacter = nil
                break
            end
        end
    end

    for _ in useEvent(UserInputService, "JumpRequest") do
        storage.lastJumpRequest = params.currentFrame
    end

    local lastInputType = UserInputService:GetLastInputType()
    local usingAltInput =
        lastInputType == Enum.UserInputType.Touch
        or lastInputType == Enum.UserInputType.Gamepad1

    for id, record, projectile, part in world:queryChanged(components.Superball, components.Projectile, components.Part, components.Owned) do
        if 
            (not usingAltInput or ((params.currentFrame - storage.lastJumpRequest) > 0.4))
            and not UserInputService:IsKeyDown(Enum.KeyCode.Space)
        then
            continue
        end

        if not storage.jumpedCharacter and record.new and not record.old and projectile.character then
            local constraints = {}

            for _, descendant in pairs(projectile.character:GetDescendants()) do
                if descendant:IsA("BasePart") then
                    local constraint = Instance.new("NoCollisionConstraint")
                    constraint.Part0 = descendant
                    constraint.Part1 = part.part
                    constraint.Parent = part.part

                    table.insert(constraints, constraint)
                end
            end

            task.delay(0, function()
                for _, constraint in pairs(constraints) do
                    constraint.Parent = nil
                end
            end)

            local v = projectile.character.PrimaryPart.AssemblyLinearVelocity
            projectile.character.PrimaryPart.AssemblyLinearVelocity = Vector3.new(v.X, projectile.character.Humanoid.JumpPower, v.Z)

            storage.jumpedCharacter = projectile.character
            overlapParams.FilterDescendantsInstances = {projectile.character}
            params.events:fire("superballJumped", id)

            break
        end
    end
end

return {
    realm = "client";
    system = superballFireDoubleJumps;
    event = "PreSimulation";
    priority = Priorities.Tools + 1;
}