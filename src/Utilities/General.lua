local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local General = {}

function General.getProjectileCFrame(tool, spawnDistance, spawnPos)
	local pos = tool:getPosition("Head")
	local dir = tool:getDirection(spawnPos, "Head")
	local at = pos + dir * spawnDistance
	
	return CFrame.lookAt(at, at + dir)
end

do
	local soundPlayer = Instance.new("Part")
	soundPlayer.Name = "CrossbowSoundPlayer"
	soundPlayer.Anchored = true
	soundPlayer.CanCollide = false
	soundPlayer.CanTouch = false
	soundPlayer.CanQuery = false
	soundPlayer.Transparency = 1
	soundPlayer.CFrame = CFrame.new(0, 0, 0)
	soundPlayer.Parent = workspace

	-- Unfortunately, PlayOnRemove doesn't respect SoundGroups. :(
	function General.play3DSound(sound, pos, soundGroup)
		local attachment = Instance.new("Attachment")
		attachment.Position = pos
		Debris:AddItem(attachment, 5)

		local clone = sound:Clone()
		clone.SoundGroup = soundGroup or SoundService.CrossbowSounds
		clone.Parent = attachment
		clone:Play()

		attachment.Parent = soundPlayer
	end
end

function General.playGlobalSound(sound, soundGroup)
	local clone = sound:Clone()
	Debris:AddItem(clone, 5)
	clone.SoundGroup = soundGroup or SoundService.CrossbowSounds
	clone.Parent = clone.SoundGroup
	clone:Play()
end

function General.getCharacter(instance)
	local parent = instance.Parent

	while parent do
		local hum = parent:FindFirstChildOfClass("Humanoid")
		if hum then
			return parent, hum
		end

		parent = parent.Parent
	end

	return nil
end

function General.getCharacterFromHitbox(instance)
	local parent = instance

	while parent and not parent:IsA("Accoutrement") do
		local hum = parent:FindFirstChildOfClass("Humanoid")
		if hum then
			return parent, hum
		end

		parent = parent.Parent
	end

	return nil
end

function General.lockTable(name, tbl)
	return table.freeze(setmetatable(tbl, {
		__index = function(_, k)
			error(("%s is not a valid member of %q"):format(k, name))
		end;
	}))
end

function General.makeEnum(name, options)
	local tbl
	
	if options[1] then
		tbl = {}
		for _, option in pairs(options) do
			tbl[option] = option
		end
	else
		tbl = options
	end

	return General.lockTable(name, tbl)
end

return General