local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Raycaster = require(script.Parent.Parent.Utilities.Raycaster)
local General = require(script.Parent.Parent.Utilities.General)

local Input = {
	Actions = General.makeEnum("Actions", {
		"Fire", "Rotate", "CancelRotate", "ToggleVisualization";
	});

	Inputs = {
		Fire = {
			Enum.KeyCode.F;
			Enum.UserInputType.Touch;
		};
		Rotate = {
			Enum.KeyCode.R;
		};
		CancelRotate = {
			Enum.KeyCode.T;
		};
		ToggleVisualization = {
			Enum.KeyCode.V;
		};
	};

	Priorities = General.makeEnum("Priorities", {
		First = 0;
		Normal = 500;
		Powerups = 600;
		Last = 1000;
	});
}

local uniqueIds = {}
local actions = {}
function Input:BindAtPriority(actionName, purpose, priority, handler)
	assert(not RunService:IsServer(), "Cannot bind action on server")

	if self.Actions[actionName] == nil then
		error(("%s is not a valid action name"):format(actionName))
	end

	local prefix = string.format("%s_%s_", actionName, purpose)
	local id
	repeat
		id = prefix .. HttpService:GenerateGUID()
	until uniqueIds[id] == nil

	local tbl = {actionName = actionName, id = id, priority = priority, handler = function(_, ...)
		return handler(...)
	end}
	uniqueIds[id] = tbl
	actions[actionName] = actions[actionName] or {}
	table.insert(actions[actionName], tbl)

	ContextActionService:BindActionAtPriority(
		id, tbl.handler, false, priority, unpack(self.Inputs[actionName])
	)

	return tbl
end

function Input:onActionKeymapChanged(actionName, keymap)
	if self.Actions[actionName] == nil then
		error(("%s is not a valid action name"):format(actionName))
	end

	self.Inputs[actionName] = keymap

	for _, bind in ipairs(uniqueIds[actionName]) do
		if bind.inputs == nil then continue end

		ContextActionService:UnbindAction(bind.id)
		ContextActionService:BindActionAtPriority(
			bind.id, bind.priority, bind.handler, unpack(keymap)
		)
	end
end

function Input:Unbind(id)
	assert(type(id) == "table" and id.actionName, "Not a valid Id!")

	uniqueIds[id] = nil
	local binds = actions[id.actionName]
	table.remove(binds, table.find(binds, id))
	ContextActionService:UnbindAction(id.id)
end

function Input:RegisterAction(actionName, inputs)
	if self.Inputs[actionName] then
		error(("%s is an already registered action name"):format(actionName))
	end

	assert(type(actionName) == "string", "Expected 'string'")
	assert(type(inputs) == "table", "Expected 'table'")

	rawset(self.Actions, actionName, true)
	self.Inputs[actionName] = inputs
end

function Input:Raycast(filter, params)
	assert(not RunService:IsServer(), "Cannot raycast on server")

	local pos = UserInputService:GetMouseLocation()
	local ray = workspace.CurrentCamera:ViewportPointToRay(pos.X, pos.Y, 0)
	local to = ray.Direction.Unit * 1000
	local result = Raycaster.withFilter(ray.Origin, to, params, filter)

	return result and result.Position or ray.Origin + to, result and result.Instance, result and result.Normal
end

function Input:IsActionHeld(actionName)
	for _, enum in pairs(self.Inputs[actionName]) do
		if enum.Name:find("Mouse") then
			if UserInputService:IsMouseButtonPressed(enum) then
				return true
			end
		elseif enum.EnumType == Enum.KeyCode then
			if UserInputService:IsKeyDown(enum) then
				return true
			end
		end
	end

	return false
end

return Input