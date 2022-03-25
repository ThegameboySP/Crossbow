local Input = require(script.Parent.Input)

local function pressActivate(tool, state, _, crossbow)
	if state == Enum.UserInputState.Begin then
		return {Input:Raycast(crossbow.Settings.Callbacks[tool.raycastFilter])}
	end
end

local function holdActivate(tool, _, checkState, fire)
	if checkState("Hold") then
		fire("toolTriggered", Input:Raycast(tool.RaycastFilter))
	end
end

return {
	default = {
		Fire = pressActivate;
	};

	Slingshot = {
		Fire = holdActivate;
	};

	Trowel = {
		Fire = pressActivate;
		Rotate = function(trowel, _, checkState, _, set)
			if checkState(Enum.UserInputState.Begin) then
				local rot = trowel.Rotation
				if trowel.IsLocked then
					local autoRot = trowel:GetAutomaticRotation((Input:Raycast(trowel.RaycastFilter)))
					rot = (math.deg(autoRot) + trowel.RotationStep) % 360
				else
					rot = (rot + trowel.RotationStep) % 360
				end
				
				set({
					IsLocked = false;
					Rotation = rot;
				})
			end
		end;

		CancelRotate = function(trowel, _, checkState, _, set)
			if checkState(Enum.UserInputState.Begin) then
				set({
					IsLocked = true;
					Rotation = 0;
				})
			end
		end;

		ToggleVisualization = function(_, _, checkState)
			if checkState(Enum.UserInputState.Begin) then
				Configuration.Trowel.VisualizationEnabled:Set(not Configuration.Trowel.VisualizationEnabled:Get())
			end
		end;
	};

	SwordTool = {
		Fire = function(_, state, storage, crossbow)
			storage.lastFired = storage.lastFired or 0

			if state == Enum.UserInputState.Begin then
				return {"Lunging"}
				-- local currentTime = crossbow.Params.currentFrame
				-- local lastFired = storage.lastFired
				-- storage.lastFired = currentTime

				-- if (currentTime - lastFired) > 0.2 then
				-- 	return {"Slashing"}
				-- else
				-- 	return {"Lunging"}
				-- end
			end
		end;
	}
}