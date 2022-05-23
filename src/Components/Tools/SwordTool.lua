local t = require(script.Parent.Parent.Parent.Parent.t)
local newComponent = require(script.Parent.Parent.Parent.Shared.newComponent)

return newComponent("SwordTool", {
	schema = {
		state = t.valueOf({"Idle", "Slashing", "Lunging"});
		
		slashSound = t.Instance;
		lungeSound = t.Instance;

		idleDamage = t.number;
		slashDamage = t.number;
		lungeDamage = t.number;

		floatAmount = t.number;
		floatHeight = t.number;
	}
})