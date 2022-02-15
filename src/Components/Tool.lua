local Players = game:GetService("Players")

local t = require(script.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Shared.newComponent)

return function()
	local Tool = newComponent("Tool", {
		schema = {
			component = t.interface({
				patch = t.callback;
			});
			
			isEquipped = t.boolean;
			reloading = t.boolean;
			reloadTimeLeft = t.number;
			character = t.optional(t.Instance);
		};
		
		defaults = {
			isEquipped = false;
			reloading = false;
			reloadTimeLeft = 0;
		};
	})

	function Tool:canFire()
		return self.isEquipped and not self.reloading and not self.firePending
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