local Input = require(script.Parent.Input)

local function pressActivate(tool, state)
	if state == Enum.UserInputState.Begin then
		return {Input:Raycast(tool.raycastFilter)}
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

	Sword = {
		Fire = function(tool, storage, checkState, fire)
			storage.lastFired = storage.lastFired or 0

			if checkState(Enum.UserInputState.Begin) then
				local currentTime = Binding:GetTime()
				if (currentTime - storage.lastFired) > 0.2 then
					fire("Slashed")
				else
					fire("Lunged")
				end

				storage.lastFired = currentTime
			end
		end;
	}
}