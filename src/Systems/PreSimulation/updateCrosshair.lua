local Players = game:GetService("Players")
local Mouse = Players.LocalPlayer:GetMouse()

local updateTools = require(script.Parent.updateTools)

local function updateCrosshair(world, components)
	local equippingTool
	local updated = false

	for _id, toolRecord in world:queryChanged(components.Tool, components.Local) do
		updated = true
		if toolRecord.new and toolRecord.new.isEquipped then
			equippingTool = toolRecord.new
			break
		end
	end

	if updated then
		if equippingTool then
			Mouse.Icon = equippingTool:canFire()
				and "rbxassetid://507449825"
				or "rbxassetid://507449806"
		else
			Mouse.Icon = ""
		end
	end
end

return {
	system = updateCrosshair;
	after = { updateTools };
	event = "PreSimulation";
}