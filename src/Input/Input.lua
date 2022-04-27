local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")

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
		_lastActionInputType = {};
	}, Input)

	crossbow:On("Update", function()
		for actionName in pairs(self._actionInputs) do
			if self._lastActionInputType[actionName] == Enum.UserInputType.Touch then
				self:SetActionState(actionName, Enum.UserInputState.End)
			elseif self:GetActionState(actionName) == Enum.UserInputState.Begin then
				self:SetActionState(actionName, "Hold")
			end
		end
	end)

	UserInputService.TouchTapInWorld:Connect(function(_, gp)
		if gp then
			return
		end

		for actionName, binds in pairs(self._actionInputs) do
			if table.find(binds, Enum.UserInputType.Touch) then
				self:SetActionState(actionName, Enum.UserInputState.Begin)
				self._lastActionInputType[actionName] = Enum.UserInputType.Touch
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

			self._lastActionInputType[actionName] = inputObject.UserInputType
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