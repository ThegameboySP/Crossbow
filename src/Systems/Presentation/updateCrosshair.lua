local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer and Players.LocalPlayer:GetMouse()

local Priorities = require(script.Parent.Parent.Priorities)

local function updateCrosshair(world, components, params)
	local equippingTool

	for _id, tool in world:query(components.Tool, components.Owned) do
		if tool.isEquipped then
			equippingTool = tool
			break
		end
	end

	if equippingTool then
		Mouse.Icon = equippingTool:canFire(params.currentFrame)
			and "rbxassetid://507449825"
			or "rbxassetid://507449806"
	else
		Mouse.Icon = ""
	end
end

return {
    realm = "client";
    system = updateCrosshair;
    event = "PostSimulation";
    priority = Priorities.Presentation;
}