local Input = require(script.Parent.Input)

local function pressActivate(tool, _, state, _, crossbow)
	if state == Enum.UserInputState.Begin then
		return {Input:Raycast(crossbow.Settings.Callbacks[tool.raycastFilter])}
	end
end

local function holdActivate(tool, _, state, _, crossbow)
	if state == "Hold" then
		return {Input:Raycast(crossbow.Settings.Callbacks[tool.raycastFilter])}
	end
end

return {
	default = {
		Fire = pressActivate;
	};

	SlingshotTool = {
		Fire = holdActivate;
	};

	TrowelTool = {
		Fire = pressActivate;
		Rotate = function(trowelTool, tool, state, _, crossbow)
			if state == Enum.UserInputState.Begin then
				local rot = trowelTool.rotation
				if trowelTool.isLocked then
					rot = (rot + trowelTool.rotationStep) % 360
				else
					local pos = Input:Raycast(crossbow.Settings.Callbacks[trowelTool.raycastFilter])
					local autoRot = trowelTool:getAutomaticRotation(tool:getDirection(pos, "Head"))
					rot = (math.deg(autoRot) + trowelTool.rotationStep) % 360
				end
				
				return nil, {
					isLocked = true;
					rotation = rot;
				}
			end
		end;

		CancelRotate = function(_, _, state)
			if state == Enum.UserInputState.Begin then
				return nil, {
					isLocked = false;
					rotation = 0;
				}
			end
		end;

		ToggleVisualization = function(_, _, state, _, crossbow)
			if state == Enum.UserInputState.Begin then
				crossbow.Settings.TrowelTool.visualizationEnabled:Set(
					not crossbow.Settings.TrowelTool.visualizationEnabled:Get()
				)
			end
		end;
	};

	SwordTool = {
		Fire = function(_, _, state, storage, crossbow)
			storage.lastFired = storage.lastFired or 0

			if state == Enum.UserInputState.Begin then
				local currentTime = crossbow.Params.currentFrame
				local lastFired = storage.lastFired
				storage.lastFired = currentTime

				if (currentTime - lastFired) > 0.2 then
					return {"Slashing"}
				else
					return {"Lunging"}
				end
			end
		end;
	}
}