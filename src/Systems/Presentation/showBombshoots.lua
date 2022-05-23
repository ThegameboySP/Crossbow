local Debris = game:GetService("Debris")

local Prefabs = script.Parent.Parent.Parent.Assets.Prefabs
local Priorities = require(script.Parent.Parent.Priorities)

local random = Random.new()
local function showBombshoots(_, _, params)
    for _, position in params.events:iterate("bombshoot") do
        local sound = params.Settings.Bomb.bombshootSound:Get():Clone()
        sound.PlaybackSpeed = random:NextNumber(0.92, 1.2)
        params.soundPlayer:queueSound(sound, nil, position)

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

return {
    realm = "client";
    system = showBombshoots;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}