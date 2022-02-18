local Players = game:GetService("Players")

local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	local Tool = newComponent("Tool", {
		defaults = {
			fireEnabled = true;
			isEquipped = false;
			reloadTimeLeft = 0;
		};

		schema = {
			componentName = t.string;
			fireEnabled = t.boolean;
			reloadTimeLeft = t.number;
			isEquipped = t.boolean;
			character = t.optional(t.Instance);
		};
	})

	function Tool:canFire()
		return self.isEquipped and self.fireEnabled and self.reloadTimeLeft <= 0
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
end