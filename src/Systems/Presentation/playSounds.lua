local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)

local function playSounds(_, _, params)
	for _, value, pos in params.events:iterate("playSound") do
		if pos then
			General.play3DSound(value:Get(), pos)
		else
			General.playGlobalSound(value:Get())
		end
	end
end

return {
	realm = "client";
	system = playSounds;
	event = "PostSimulation";
	priority = Priorities.Presentation + 9;
}