local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return function()
	return newComponent("SwordTool", {
		schema = {
			state = t.valueOf({"Idle", "Slashing", "Lunging"});
			
			idleDamage = t.number;
			slashDamage = t.number;
			lungeDamage = t.number;

			floatAmount = t.number;
			floatHeight = t.number;
		}
	})
end