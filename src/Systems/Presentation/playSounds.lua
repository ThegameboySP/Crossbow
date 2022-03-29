local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)

local function playSounds(_, _, params)
	for _, sound, pos in params.events:iterate("playSound") do
		if pos then
			General.play3DSound(sound, pos)
		else
			General.playGlobalSound(sound)
		end
	end
end

return {
	realm = "client";
	system = playSounds;
	event = "PostSimulation";
	priority = Priorities.Presentation + 9;
}