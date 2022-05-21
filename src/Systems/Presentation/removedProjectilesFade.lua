local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")

local Priorities = require(script.Parent.Parent.Priorities)
local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function removedProjectilesFade(world, components, params)
    for _, id in params.events:iterate("queueRemove") do
        local projectile = world:get(id, components.Projectile)
        if not projectile or (projectile.componentName ~= "Superball" and projectile.componentName ~= "SlingshotPellet") then
            continue
        end

        local part = world:get(id, components.Part)
        if part == nil then
            continue
        end
        
        local clone = part.part:Clone()
        PhysicsService:SetPartCollisionGroup(clone, "Crossbow_VisualNoCollision")
        clone.Parent = part.part.Parent

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
    priority = Priorities.Presentation;
}