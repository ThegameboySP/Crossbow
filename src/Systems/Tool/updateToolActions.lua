local RunService = game:GetService("RunService")

local Matter = require(script.Parent.Parent.Parent.Parent.Matter)

local InputStrategies = require(script.Parent.Parent.Parent.Input.InputStrategies)
local Input = require(script.Parent.Parent.Parent.Input.Input)

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)
local updateTools = require(script.Parent.updateTools)

local IS_SERVER = RunService:IsServer()

local function resolveState(isHeld, wasHeld)
	if isHeld and not wasHeld then
		return Enum.UserInputState.Begin
	elseif isHeld and wasHeld then
		return "Hold"
	elseif not isHeld and wasHeld then
		return Enum.UserInputState.End
	else
		return Enum.UserInputState.None
	end
end

local activations = {}
local function handleInput(world, id, tool, crossbow)
	local actions = InputStrategies[tool:getDefinition().componentName] or InputStrategies.default
	if actions == nil then
		return
	end
	
	local storage = useHookStorage(actions)
	storage.customStorage = storage.customStorage or {}
	
	for actionName, strategy in pairs(actions) do
		
		local customStorage = storage.customStorage[actionName]
		if customStorage == nil then
			customStorage = {}
			storage.customStorage[actionName] = customStorage
		end
		
		local isHeld = Input:IsActionHeld(actionName)
		local event, patch = strategy(tool, resolveState(isHeld, customStorage.wasHeld), customStorage, crossbow)
		customStorage.wasHeld = isHeld
		
		if event then
			table.insert(activations, {name = actionName, tool = tool, id = id, event = event})
		end
		
		if patch then
			world:insert(id, tool:patch(patch))
		end
	end
end

local function useToolActions(world, components, params)
	-- Run input checks for tool actions.
	if not params.Crossbow.IsServer then
		debug.profilebegin("input")

		for id, tool in world:query(components.Tool, components.Local) do
			if tool.isEquipped then
				handleInput(world, id, world:get(id, components[tool.componentName]), params.Crossbow)
			end
		end
		
		debug.profileend()
	end
	
	for index, activation in ipairs(activations) do
		activations[index] = nil
		if activation.name == "Fire"
			and
				(not world:get(activation.id, components.Tool):canFire()
				or (activation.event[1] == nil
					and activation.tool.onlyActivateOnPartHit))
		then 
			continue 
		end
		
		params.events:fire("tool-activated-" .. string.lower(activation.name), activation.id, unpack(activation.event))
	end
	
	-- Assign components to projectiles according to tool's pack.
	for _, id, pos in params.events:iterate("tool-activated-fire") do
		local tool = world:get(id, components.Tool)
		local specificTool = world:get(id, components[tool.componentName])

		local toolType = specificTool:getDefinition().toolType
		if toolType == "Projectile" then
			world:insert(id, tool:patch({
				reloadTimeLeft = specificTool.reloadTime;
			}))

			local cframe = specificTool.getProjectileCFrame(tool, specificTool.spawnDistance, pos)
			world:spawn(
				components.Local(),
				params.Crossbow.Packs[specificTool.pack](id, tool.character, specificTool.velocity, cframe)
			)

			local fireSound = params.Settings[tool.componentName].fireSound:Get()
			if fireSound then
				params.events:fire("playSound", fireSound, cframe.Position, id)
			end
		end
	end
	
	for id, projectile in world:query(components.Projectile):without(components.Instance) do
		local tool = world:get(projectile.spawnerId, components.Tool)
		local specificTool = world:get(projectile.spawnerId, components[tool.componentName])
		
		local part = specificTool.prefab:Clone()
		params.Crossbow:InsertBind(part, id)
		part.Parent = workspace
		if IS_SERVER then
			part:SetNetworkOwner(nil)
		end
	end
end

return {
	system = useToolActions;
	event = "PreSimulation";
	after = { updateTools };
	priority = Priorities.Tools;
}