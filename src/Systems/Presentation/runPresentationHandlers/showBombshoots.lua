local Debris = game:GetService("Debris")

local Prefabs = script.Parent.Parent.Parent.Parent.Assets.Prefabs

local function showBombshoots(_, _, params)
    for _, position in params.events:iterate("bombshoot") do
        params.soundPlayer:queueSound(params.Settings.Bomb.bombshootSound:Get(), nil, position)
        local part = Instance.new("Part")
        part.Anchored = true
        part.CanCollide = false
        part.Size = Vector3.zero
        part.Transparency = 1
        part.CFrame = CFrame.new(position)

        local emitter = Prefabs.BombshootParticle:Clone()
        emitter.Enabled = false
        emitter.Parent = part
        emitter:Emit(1)
        Debris:AddItem(part, 2)

        part.Parent = workspace
    end
end

return showBombshoots