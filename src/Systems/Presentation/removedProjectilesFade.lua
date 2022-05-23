local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

local Priorities = require(script.Parent.Parent.Priorities)
local removeQueued = require(script.Parent.Parent.Core.removeQueued)
local Components = require(script.Parent.Parent.Parent.Components)

local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function removedProjectilesFade(_, params)
    -- Don't use :queryChanged here because we need access to various of its old Components.
    for _, removedBin in pairs(params.removedBins) do
        if not removedBin[Components.Superball] and not removedBin[Components.SlingshotPellet] then
            continue
        end

        local part = removedBin[Components.Part]
        if part == nil then
            continue
        end
        
        local clone = part.part:Clone()
        PhysicsService:SetPartCollisionGroup(clone, "Crossbow_VisualNoCollision")
        clone.Parent = workspace

        local tween = TweenService:Create(clone, TWEEN_INFO, {Size = Vector3.zero})
        tween.Completed:Connect(function()
            clone.Parent = nil
        end)
        
        tween:Play()
    end
end

return {
    realm = "client";
    system = removedProjectilesFade;
    event = "PostSimulation";
    priority = Priorities.CoreAfter + 9;
    after = { removeQueued };
}