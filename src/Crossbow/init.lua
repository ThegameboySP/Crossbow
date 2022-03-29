local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Prefabs = script.Parent.Assets.Prefabs

local Matter = require(script.Parent.Parent.Matter)
local Definitions = require(script.Parent.Shared.Definitions)
local Filters = require(script.Parent.Utilities.Filters)
local Signal = require(script.Parent.Utilities.Signal)

local Events = require(script.Events)
local Observers = require(script.Observers)
local packs = require(script.packs)
local settings = require(script.settings)
local bindSignals = require(script.bindSignals)

local Crossbow = {}
Crossbow.__index = Crossbow

local IS_SERVER = RunService:IsServer()

function Crossbow.new()
	local params = {}
	local world = Matter.World.new()

	local self = setmetatable({
		Components = nil;
		Settings = nil;
		Packs = nil;

		IsServer = IS_SERVER;
		IsTesting = false;
		Initialized = false;
	
		Params = params;
		World = world;
		Loop = nil;
		_systemsSet = {};
		
		_signals = {};

		Tools = {};
		Observers = Observers.new();
	}, Crossbow)

	local listeners = {}
	local function onInit(...)
		table.insert(listeners, table.pack( ... ))
		return ...
	end

	self.Settings = settings(self, onInit)
	self.Packs = packs(self, onInit)
	self.Components = self:_getComponents(script.Parent.Components)

	for _, listener in ipairs(listeners) do
		listener[listener.n](unpack(listener, 1, listener.n - 1))
	end

	self.Loop = Matter.Loop.new(world, self.Components, params)

	return self
end

function Crossbow:PopulateParams()
	self.Params.Crossbow = self
	self.Params.Settings = self.Settings
	self.Params.Packs = self.Packs
	self.Params.events = Events.new()
	self.Params.remoteEvents = Events.new()
	self.Params.entityKey = self.IsServer and "serverEntityId" or "clientEntityId"
	self.Params.serverToClientId = {}
	self.Params.clientToServerId = {}
	self.Params.currentFrame = 0
	self.Params.previousFrame = 0
	self.Params.deltaTime = 0
end

function Crossbow:Init()
	if self.Initialized then return end
	self.Initialized = true
	
	self:PopulateParams()
	self:_registerSystems(script.Parent.Systems)

	CollectionService:GetInstanceRemovedSignal("CrossbowInstance"):Connect(function(instance)
		local id = instance:GetAttribute(self.Params.entityKey)
		if id and self.World:contains(id) then
			self.World:despawn(id)
		end
	end)

	if not self.IsTesting then
		if IS_SERVER then
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "CrossbowRemoteEvent"
			remoteEvent.Parent = ReplicatedStorage
			self.Params.remoteEvent = remoteEvent
		else
			self.Params.remoteEvent = ReplicatedStorage:WaitForChild("CrossbowRemoteEvent")

			local soundGroup = Instance.new("SoundGroup")
			soundGroup.Name = "CrossbowSounds"
			soundGroup.Parent = SoundService
		end
	end

	assert(Definitions.params(self.Params))

	local params = self.Params
	self.Loop:begin(bindSignals(function(nextFn, signalName)
		return function()
			if 
				(IS_SERVER and signalName == "PreSimulation")
				or (not IS_SERVER and signalName == "PreRender")
			then
				local timestamp = workspace:GetServerTimeNow()
				params.currentFrame, params.previousFrame = timestamp, params.currentFrame or timestamp
				params.deltaTime = params.previousFrame and (timestamp - params.previousFrame) or 0
			end

			nextFn()

			if signalName == "PostSimulation" then
				for name, event in params.events:iterateAll() do
					local signal = self._signals[name]
					if signal then
						signal:Fire(unpack(event, 1, event.n))
					end
				end

				params.events:clear()
				params.remoteEvents:clear()
			end
		end
	end))
end

function Crossbow:RegisterDefaultTools()
	self:RegisterTool("Sword", Prefabs.SwordTool, self.Packs.SwordTool)
	self:RegisterTool("Superball", Prefabs.SuperballTool, self.Packs.SuperballTool)
	self:RegisterTool("Rocket", Prefabs.RocketTool, self.Packs.RocketTool)
	self:RegisterTool("Bomb", Prefabs.BombTool, self.Packs.BombTool)
	self:RegisterTool("Trowel", Prefabs.TrowelTool, self.Packs.TrowelTool)
	-- self:RegisterTool("Slingshot", Prefabs.slingshotTool, Packs.slingshotTool)
end

function Crossbow:On(signalName, handler)
	local signal = self._signals[signalName]
	if signal == nil then
		signal = Signal.new()
		self._signals[signalName] = signal
	end

	return signal:Connect(handler)
end

function Crossbow:GetProjectile(part)
	local id = part:GetAttribute(self.Params.entityKey)

	if id and self.World:contains(id) then
		local projectile = self.World:get(id, self.Components.Projectile)
		if projectile then
			return id, projectile, self.World:get(id, self.Components[projectile.componentName])
		end
	end

	return nil
end

function Crossbow:RegisterTool(name, prefab, pack)
	local entry = {
		prefab = prefab;
		pack = pack;
		shouldAdd = Filters.always;
	}

	self.Tools[name] = entry
	return entry
end

function Crossbow:_errorIfBound(instance, newId)
	local id = instance:GetAttribute(self.Params.entityKey)

	if id and id ~= newId and self.World:contains(id) then
		local component = self.World:get(id, self.Components.Instance)

		if component and component.instance == instance then
			error(("%s is already bound to a Matter entity. Did you forget to remove the Instance component?"):format(instance:GetFullName()), 3)
		end
	end
end

function Crossbow:SpawnBind(instance, ...)
	self:_errorIfBound(instance)
	return self:InsertBind(instance, self.World:spawn(), ...)
end

function Crossbow:InsertBind(instance, id, ...)
	self:Bind(instance, id)

	local part
	if instance:IsA("BasePart") then
		part = instance
	elseif instance:IsA("Tool") and instance:FindFirstChild("Handle") then
		part = instance:FindFirstChild("Handle")
	end
	
	if part then 
		return id, self.World:insert(id,
			self.Components.Part({
				part = part;
			}),
			self.Components.Instance({
				instance = instance;
			}),
			...
		)	
	else
		return id, self.World:insert(id, self.Components.Instance({
			instance = instance;
		}), ...)
	end
end

function Crossbow:Bind(instance, id)
	self:_errorIfBound(instance, id)
	instance:SetAttribute(self.Params.entityKey, id)
	CollectionService:AddTag(instance, "CrossbowInstance")
end

function Crossbow:AddToolsToCharacter(character)
	local player = Players:GetPlayerFromCharacter(character)
	local backpack = player.Backpack

	for _, entry in pairs(self.Tools) do
		if not entry.shouldAdd(character) then continue end

		local tool = entry.prefab:Clone()

		self:SpawnBind(tool, self.Components.Owner({client = player}), entry.pack(character))
		tool.Parent = backpack
	end
end

function Crossbow:AutoAddTools()
	local playerCons = {}

	local function onPlayerAdded(player)
		local function onCharacterAdded(character)
			if not character.Parent then
				character.AncestryChanged:Wait()
			end

			self:AddToolsToCharacter(character)
			-- self:FireRemote("ToolsAdded", character)
		end

		playerCons[player] = player.CharacterAdded:Connect(onCharacterAdded)
		if player.Character then
			task.spawn(onCharacterAdded, player.Character)
		end
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	for _, player in pairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		playerCons[player]:Disconnect()
		playerCons[player] = nil
	end)
end

-- remove all projectiles & all else required between meta / rep-mode switches
function Crossbow:Reset()

end

function Crossbow:_registerSystems(target)
	local newSystems = {}

	forEachModulescript(target, function(module)
		if module.name:find(".spec$") then return end

		local source = require(module)
		if table.isfrozen(source) then return end
		
		assert(Definitions.system(source))

		if
			(source.realm == "server" and not self.IsServer)
			or (source.realm == "client" and self.IsServer)
		then
			return
		end

		if not self._systemsSet[source] then
			self._systemsSet[source] = true
			table.insert(newSystems, source)
		end
	end)

	self.Loop:scheduleSystems(newSystems)
end

function Crossbow:_getComponents(target)
	local components = {}

	forEachModulescript(target, function(module)
		local getComponent = require(module)
		local component = getComponent(self.Settings) or error("No component returned by module: " .. module.Name)
		components[module.Name] = component
	end)

	return setmetatable(components, {__index = function(_, k)
		error(("No component named %q!"):format(k), 2)
	end})
end

function forEachModulescript(target, handler)
	for _, child in pairs(target:GetChildren()) do
		if child:IsA("ModuleScript") then
			handler(child)
		elseif child:IsA("Folder") then
			forEachModulescript(child, handler)
		end
	end
end

return Crossbow.new()