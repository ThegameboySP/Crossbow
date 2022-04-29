local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

local InputStrategies = require(script.Parent.Parent.Parent.Input.InputStrategies)

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)
local updateTools = require(script.Parent.updateTools)

local IS_SERVER = RunService:IsServer()

local activations = {}
local function handleInput(world, id, specificTool, tool, crossbow)
	local actions = InputStrategies[specificTool:getDefinition().componentName] or InputStrategies.default
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
		
		local event, patch = strategy(specificTool, tool, crossbow.Input:GetActionState(actionName), customStorage, crossbow)
		
		if event then
			table.insert(activations, {name = actionName, tool = specificTool, id = id, event = event})
		end
		
		if patch then
			world:insert(id, specificTool:patch(patch))
		end
	end
end

local function useToolActions(world, components, params)
	-- Run input checks for tool actions.
	if not params.Crossbow.IsServer then
		debug.profilebegin("input")

		for id, tool in world:query(components.Tool, components.Owned) do
			if tool.isEquipped then
				handleInput(world, id, world:get(id, components[tool.componentName]), tool, params.Crossbow)
				break
			end
		end
		
		debug.profileend()
	end
	
	for index, activation in ipairs(activations) do
		activations[index] = nil
		local tool = world:get(activation.id, components.Tool)
		if activation.name == "Fire"
			and
				(not tool:canFire(params.currentFrame)
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
				nextReloadTimestamp = params.currentFrame + tool.reloadTime;
			}))

			local cframe = specificTool.getProjectileCFrame(tool, specificTool.spawnDistance, pos, specificTool)
			world:spawn(
				components.Owned(),
				params.Crossbow.Packs[specificTool.pack](id, tool.character, specificTool.velocity, cframe)
			)

			if tool.fireSound then
				params.soundPlayer:queueSound(tool.fireSound, id, cframe.Position)
			end
		end
	end

	for id, projectileRecord in world:queryChanged(components.Projectile) do
		if projectileRecord.old == nil and world:get(id, components.Instance) == nil then
			local tool = world:get(projectileRecord.new.spawnerId, components.Tool)
			local specificTool = world:get(projectileRecord.new.spawnerId, components[tool.componentName])
			
			local part = specificTool.prefab:Clone()
			params.Crossbow:InsertBind(part, id)
			PhysicsService:SetPartCollisionGroup(part, "Crossbow_Projectile")
			CollectionService:AddTag(part, "Projectile")
			part.Parent = workspace

			if IS_SERVER then
				part:SetNetworkOwner(nil)
			end
		end
	end
end

return {
	system = useToolActions;
	event = "PreSimulation";
	after = { updateTools };
	priority = Priorities.Tools;
}