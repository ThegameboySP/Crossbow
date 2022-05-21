local TweenService = game:GetService("TweenService")

local Priorities = require(script.Parent.Parent.Priorities)

local function newGui(position, damage)
    local scale = math.clamp(damage / 25, 0.5, 1)

	local part = Instance.new("Part")
	part.Anchored = true
	part.CFrame = CFrame.new(position)
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Name = "HealthGuiHolder"
	
	local gui = Instance.new("BillboardGui")
	gui.ResetOnSpawn = false
	gui.Size = UDim2.fromScale(10 * scale, 2 * scale)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.Brightness = 2
	gui.LightInfluence = 0.5
	gui.Adornee = part
	gui.Parent = part
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 67, 43)
	textLabel.Text = tostring(damage)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextScaled = true
	textLabel.Parent = gui
	
	part.Parent = workspace
	
	local tween = TweenService:Create(
		textLabel,
		TweenInfo.new(scale * 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{Position = UDim2.fromScale(0, -0.5)}
	)
	tween:Play()
	tween.Completed:Connect(function()
		part.Parent = nil
	end)
	
	return part
end

local function showDamage(_, _, params)
    for _, record in params.events:iterate("damaged") do
        local head = record.humanoid.Parent:FindFirstChild("Head")
        if head then
            newGui(head.Position, record.damage)
        end
    end
end

return {
    realm = "client";
    system = showDamage;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}