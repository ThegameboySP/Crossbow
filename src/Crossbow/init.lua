local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Prefabs = script.Parent.Assets.Prefabs

local Matter = require(script.Parent.Parent.Matter)
local Definitions = require(script.Parent.Shared.Definitions)
local Filters = require(script.Parent.Utilities.Filters)
local Signal = require(script.Parent.Utilities.Signal)
local Input = require(script.Parent.Input.Input)
local Components = require(script.Parent.Components)

local HotReloader = require(script.HotReloader)
local defaultBindings = require(script.defaultBindings)
local SoundPlayer = require(script.SoundPlayer)
local Events = require(script.Events)
local packs = script.packs
local settings = script.settings
local bindSignals = require(script.bindSignals)

local Crossbow = {}
Crossbow.__index = Crossbow

local IS_SERVER = RunService:IsServer()

local function makeOnInit()
	local listeners = {}
	local function onInit(...)
		table.insert(listeners, table.pack( ... ))
		return ...
	end

	return onInit, function()
		for _, listener in ipairs(listeners) do
			listener[listener.n](unpack(listener, 1, listener.n - 1))
		end
	end
end

function Crossbow.new()
	local params = {}
	local world = Matter.World.new()

	local self = setmetatable({
		Settings = nil;
		Packs = nil;
		Input = nil;

		IsServer = IS_SERVER;
		IsTesting = false;
		Initialized = false;
	
		Params = params;
		World = world;
		Loop = nil;
		Signals = setmetatable({}, {__index = function(t, key)
			local signal = Signal.new()
			t[key] = signal
			return signal
		end});

		Tools = {};
	}, Crossbow)

	local hotReloader = HotReloader.new()
	local function reload()
		local onInit, init = makeOnInit()

		local newSettings = require(hotReloader:getLatest(settings))(self, onInit)
		local newPacks = require(hotReloader:getLatest(packs))(self, onInit)

		self.Params.Settings = newSettings
		self.Settings = newSettings
		self.Params.Packs = newPacks
		self.Packs = newPacks
		init()
	end

	for _, sourceModule in pairs({settings, packs}) do
		hotReloader:listen(sourceModule, reload)
	end
	
	reload()
	self.Loop = Matter.Loop.new(world, params)

	return self
end

function Crossbow:Init(systems, customBindSignals)
	if self.Initialized then return end
	self.Initialized = true
	
	self.Params.Crossbow = self
	self.Params.Settings = self.Settings
	self.Params.Packs = self.Packs
	self.Params.events = Events.new()
	self.Params.remoteEvents = Events.new()
	self.Params.entityKey = self.IsServer and "serverEntityId" or "clientEntityId"
	self.Params.serverToClientId = {}
	self.Params.clientToServerId = {}
	self.Params.hitQueue = {}
	self.Params.removedBins = {}
	self.Params.currentFrame = 0
	self.Params.previousFrame = 0
	self.Params.deltaTime = 0

	if systems then
		self.Loop:scheduleSystems(systems)
	else
		self:_registerSystems(script.Parent.Systems)
	end

	CollectionService:GetInstanceRemovedSignal("CrossbowInstance"):Connect(function(instance)
		local id = instance:GetAttribute(self.Params.entityKey)
		if id and self.World:contains(id) then
			self.World:despawn(id)
		end
	end)

	if self.IsTesting then
		self.Params.soundPlayer = SoundPlayer.new(nil, nil)
	else
		if IS_SERVER then
			PhysicsService:CreateCollisionGroup("Crossbow_Visual")
			PhysicsService:CreateCollisionGroup("Crossbow_Projectile")
			PhysicsService:CreateCollisionGroup("Crossbow_VisualNoCollision", "Crossbow_VisualNoCollision", false)
			PhysicsService:CollisionGroupSetCollidable("Crossbow_Visual", "Crossbow_Projectile", false)
			PhysicsService:CollisionGroupSetCollidable("Crossbow_Visual", "Crossbow_Visual", false)
			PhysicsService:CollisionGroupSetCollidable("Crossbow_VisualNoCollision", "Crossbow_Projectile", false)
			PhysicsService:CollisionGroupSetCollidable("Crossbow_VisualNoCollision", "Crossbow_Visual", false)
			PhysicsService:CollisionGroupSetCollidable("Crossbow_VisualNoCollision", "Default", false)

			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "CrossbowRemoteEvent"
			remoteEvent.Parent = ReplicatedStorage
			self.Params.remoteEvent = remoteEvent
		else
			self.Params.remoteEvent = ReplicatedStorage:WaitForChild("CrossbowRemoteEvent")

			self.Input = Input.new(self)
			for actionName, inputs in pairs(defaultBindings) do
				self.Input:RegisterAction(actionName, unpack(inputs))
			end

			local soundGroup = Instance.new("SoundGroup")
			soundGroup.Name = "CrossbowSounds"
			soundGroup.Parent = SoundService

			local soundRoot = Instance.new("Part")
			soundRoot.Name = "CrossbowSoundPlayer"
			soundRoot.Anchored = true
			soundRoot.CanCollide = false
			soundRoot.CanTouch = false
			soundRoot.CanQuery = false
			soundRoot.Transparency = 1
			soundRoot.CFrame = CFrame.new(0, 0, 0)
			soundRoot.Parent = workspace

			self.Params.soundPlayer = SoundPlayer.new(soundRoot, soundGroup)
		end
	end

	assert(Definitions.params(self.Params))

	local params = self.Params
	self.Loop:begin((customBindSignals or bindSignals)(function(nextFn, signalName)
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
					local signal = rawget(self.Signals, name)
					if signal then
						signal:Fire(unpack(event, 1, event.n))
					end
				end

				self.Signals.Update:Fire()

				params.events:clear()
				params.remoteEvents:clear()
			end
		end
	end))
end

function Crossbow:RegisterDefaultTools()
	self:RegisterTool("Sword", Prefabs.SwordTool, "SwordTool")
	self:RegisterTool("Superball", Prefabs.SuperballTool, "SuperballTool")
	self:RegisterTool("Rocket", Prefabs.RocketTool, "RocketTool")
	self:RegisterTool("Bomb", Prefabs.BombTool, "BombTool")
	self:RegisterTool("Trowel", Prefabs.TrowelTool, "TrowelTool")
	self:RegisterTool("Slingshot", Prefabs.SlingshotTool, "SlingshotTool")
	self:RegisterTool("Paintball", Prefabs.PaintballTool, "PaintballTool")
end

function Crossbow:GetProjectile(part)
	if not CollectionService:HasTag(part, "CrossbowInstance") then
		return nil
	end
	
	local id = part:GetAttribute(self.Params.entityKey)

	if id and self.World:contains(id) then
		local projectile = self.World:get(id, Components.Projectile)
		if projectile then
			return id, projectile, self.World:get(id, Components[projectile.componentName])
		end
	end

	return nil
end

function Crossbow:RegisterTool(name, prefab, packName)
	local entry = {
		prefab = prefab;
		packName = packName;
		shouldAdd = Filters.always;
	}

	self.Tools[name] = entry
	return entry
end

function Crossbow:_errorIfBound(instance, newId)
	local id = instance:GetAttribute(self.Params.entityKey)

	if id and id ~= newId and self.World:contains(id) then
		local component = self.World:get(id, Components.Instance)

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
			Components.Part({
				part = part;
			}),
			Components.Instance({
				instance = instance;
			}),
			...
		)	
	else
		return id, self.World:insert(id, Components.Instance({
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

		local pack = self.Packs[entry.packName]
		self:SpawnBind(tool, Components.Owner({client = player}), pack(character))
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
	local namesBySystem = {}

	forEachModulescript(target, function(module)
		if module.name:find("%.spec$") then return end

		local source = require(module)
		if table.isfrozen(source) then return end
		
		assert(Definitions.system(source))

		if
			(source.realm == "server" and not self.IsServer)
			or (source.realm == "client" and self.IsServer)
		then
			return
		end

		namesBySystem[source] = module.Name
		table.insert(newSystems, source)
	end)

	-- Optimization: Crossbow should never nest Loops, so we can actually combine
	-- all systems into one system per event. It won't have to restart TopoRuntime or
	-- create a new coroutine for every system.
	local loop = Matter.Loop.new()
	loop:scheduleSystems(newSystems)
	local orderedSystemsByEvent = loop._orderedSystemsByEvent

	for _, eventName in ipairs({"PreRender", "PreSimulation", "PostSimulation"}) do
		self.Loop:scheduleSystem({
			event = eventName;
			system = function(world, components, params)
				for _, system in ipairs(orderedSystemsByEvent[eventName] or {}) do
					debug.profilebegin(namesBySystem[system])

					xpcall(system.system, function(err)
						task.spawn(error, debug.traceback(err, 2))
					end, world, components, params)

					debug.profileend()
				end
			end;
		})
	end
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