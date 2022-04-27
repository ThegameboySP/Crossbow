local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Raycaster = require(script.Parent.Parent.Utilities.Raycaster)

local Input = {}
Input.__index = Input

local function actionNameFn(actionName)
	return "Crossbow_" .. actionName
end

function Input.new(crossbow)
	assert(not crossbow.IsServer, "Cannot create Input on server")

	local self = setmetatable({
		_crossbow = crossbow;
		_actionStates = {};
		_actionInputs = {};
	}, Input)

	crossbow.Signals.Update:Connect(function()
		for actionName in pairs(self._actionInputs) do
			if self:GetActionState(actionName) == Enum.UserInputState.Begin then
				self:SetActionState(actionName, "Hold")
			end
		end
	end)

	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	-- ContextActionService seems to be faster than its UIS counterparts.
	ContextActionService:BindAction(
		"Crossbow_Touch",
		function(_, state, inputObject)
			if state == Enum.UserInputState.Begin then
				local pos = inputObject.Position
				for _, gui in pairs(PlayerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)) do
					-- funny hack
					-- really, is there no better way to handle this?
					if gui.Name == "DynamicThumbstickFrame" then
						return Enum.ContextActionResult.Pass
					end
				end

				for actionName, binds in pairs(self._actionInputs) do
					if table.find(binds, Enum.UserInputType.Touch) then
						self:SetActionState(actionName, Enum.UserInputState.Begin)
					end
				end

				return Enum.ContextActionResult.Pass
			end
		end,
		false,
		Enum.UserInputType.Touch
	)

	-- TouchEnded fires even if hovering over a GUI.
	UserInputService.TouchEnded:Connect(function()
		for actionName, binds in pairs(self._actionInputs) do
			if table.find(binds, Enum.UserInputType.Touch) then
				self:SetActionState(actionName, Enum.UserInputState.End)
			end
		end
	end)

	return self
end

function Input:RegisterAction(actionName, ...)
	assert(type(actionName) == "string", "Expected 'string'")

	local oldActionInputs = self._actionInputs[actionName]
	self._actionInputs[actionName] = table.freeze({...})

	if oldActionInputs then
		ContextActionService:UnbindAction(actionNameFn(actionName))
	end

	ContextActionService:BindActionAtPriority(
		actionNameFn(actionName), 
		function(_, inputState, inputObject)
			if inputObject.UserInputType == Enum.UserInputType.Touch then
				return Enum.ContextActionResult.Pass
			end
			
            if inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.End then
                self:SetActionState(actionName, inputState)
			end

			return Enum.ContextActionResult.Pass
		end,
		false,
		100,
		...
	)
end

function Input:Raycast(filter, params)
	local pos = UserInputService:GetMouseLocation()
	local ray = workspace.CurrentCamera:ViewportPointToRay(pos.X, pos.Y, 0)
	local to = ray.Direction.Unit * 1000
	local result = Raycaster.withFilter(ray.Origin, to, params, filter)

	return result and result.Position or ray.Origin + to, result and result.Instance, result and result.Normal
end

function Input:SetActionState(actionName, actionState)
	self._actionStates[actionName] = actionState
end

function Input:GetActionState(actionName)
	return self._actionStates[actionName]
end

return Input