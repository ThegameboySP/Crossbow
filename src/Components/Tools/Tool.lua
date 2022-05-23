local Players = game:GetService("Players")

local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

local Tool = newComponent("Tool", {
	replicateKeys = {
		componentName = true;
		character = true;
		equipSound = true;
		fireSound = true;
		reloadTime = true;
		nextReloadTimestamp = true;
	};

	defaults = {
		fireEnabled = true;
		isEquipped = false;
		nextReloadTimestamp = 0;
	};

	schema = {
		componentName = t.string;
		fireEnabled = t.boolean;
		nextReloadTimestamp = t.number;
		reloadTime = t.number;
		
		isEquipped = t.boolean;
		character = t.optional(t.Instance);
		equipSound = t.optional(t.Instance);
		fireSound = t.optional(t.Instance);
	};
})

function Tool:canFire(timestamp)
	return self.isEquipped and self.fireEnabled and timestamp - self.nextReloadTimestamp >= 0
end

function Tool:getPlayer()
	local char = self.character
	if char then
		return Players:GetPlayerFromCharacter(char)
	end

	return nil
end

function Tool:getHead()
	local char = self.character
	if char == nil then
		return nil
	end

	return char:FindFirstChild("Head")
end

function Tool:getHumanoid()
	local char = self.character
	if char == nil then
		return nil
	end

	return char:FindFirstChildOfClass("Humanoid")
end

function Tool:getDirection(pos, name)
	local char = self.character
	local part = char and char:FindFirstChild(name)
	return part and (pos - part.Position).Unit or Vector3.zero
end

function Tool:getPosition(name)
	local char = self.character
	local part = char and char:FindFirstChild(name)
	return part and part.Position or Vector3.zero
end

return Tool