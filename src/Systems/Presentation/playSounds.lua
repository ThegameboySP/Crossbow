local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)

local function playSounds(_, _, params)
	local Sounds = params.Settings.Sounds

	for _, soundName, pos in params.events:iterate("playSound") do
		local sound = rawget(Sounds, soundName)
		if sound == nil then
			task.spawn(error, ("%q is not a valid sound name!"):format(soundName))
			continue
		end

		if pos then
			General.play3DSound(sound:Get(), pos)
		else
			General.playGlobalSound(sound:Get())
		end
	end
end

return {
	realm = "client";
	system = playSounds;
	event = "PostSimulation";
	priority = Priorities.Presentation;
}