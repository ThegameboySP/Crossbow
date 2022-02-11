local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Matter = require(script.Parent.Parent.Matter)
local bindSignals = require(script.Parent.bindSignals)

local Prefabs = script.Parent.Assets.Prefabs

local Components = require(script.Parent.Components)
local Definitions = require(script.Parent.Shared.Definitions)
local Events = require(script.Parent.Utilities.Events)
local Filters = require(script.Parent.Utilities.Filters)
local Observers = require(script.Parent.Utilities.Observers)
local Packs = require(script.Parent.Shared.Packs)
local Configuration = require(script.Parent.Shared.Configuration)

local Crossbow = {}
Crossbow.__index = Crossbow

local IS_SERVER = RunService:IsServer()

function Crossbow.new()
	local params = {}
	local world = Matter.World.new()

	return setmetatable({
		Components = Components;
		
		IsServer = IS_SERVER;
		IsTesting = false;
		Initialized = false;
	
		Params = params;
		World = world;
		Loop = Matter.Loop.new(world, params);
		_systemsSet = {};
	
		Configuration = Configuration;
		Tools = {};
		Observers = Observers.new();
	}, Crossbow)
end

function Crossbow:PopulateParams()
	self.Params.Crossbow = self
	self.Params.events = Events.new()
	self.Params.remoteEvent = Instance.new("RemoteEvent")
	self.Params.entityKey = self.IsServer and "serverEntityId" or "clientEntityId"
end

function Crossbow:Init()
	if self.Initialized then return end
	self.Initialized = true
	
	self:PopulateParams()
	self:_registerSystems(script.Parent.Systems)

	local params = self.Params
	self.Loop:begin(bindSignals(function(nextFn, signalName)
		return function()
			debug.profilebegin("Crossbow")

			if 
				(IS_SERVER and signalName == "PreSimulation")
				or (not IS_SERVER and signalName == "PreRender")
			then
				local timestamp = os.clock()
				params.deltaTime = params.previousFrame and (timestamp - params.previousFrame) or 0
				params.currentFrame, params.previousFrame = timestamp, params.currentFrame or timestamp
			end

			nextFn()

			if signalName == "PostSimulation" then
				table.clear(params.events)
			end

			debug.profileend()
		end
	end))

	if IS_SERVER and not self.IsTesting then
		self.remoteEvent = Instance.new("RemoteEvent")
		self.remoteEvent.Name = "CrossbowRemoteEvent"
		self.remoteEvent.Parent = ReplicatedStorage

		local soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = "CrossbowSounds"
		soundGroup.Parent = SoundService

		-- task.defer(function()
		-- 	self.remoteEvent.OnServerEvent:Connect(function(player, eventName, ...)
		-- 		self.Observers:Fire("Client" .. eventName, player, ...)
		-- 	end)
		-- end)
	-- elseif not IS_SERVER and not self.IsTesting then
	-- 	self.remoteEvent = ReplicatedStorage:WaitForChild("CrossbowRemoteEvent")

	-- 	task.defer(function()
	-- 		self.remoteEvent.OnClientEvent:Connect(function(eventName, ...)
	-- 			self.Observers:Fire("Server" .. eventName, ...)
	-- 			self.Observers:Fire(eventName, ...)
	-- 		end)
	-- 	end)
	-- end
	end
end

function Crossbow:FireRemote(eventName, ...)
	if IS_SERVER then
		self.remoteEvent:FireAllClients(eventName, ...)
	else
		self.remoteEvent:FireServer(eventName, ...)
	end
end

function Crossbow:RegisterDefaultTools()
	-- self:RegisterTool("Superball", Prefabs.superballTool, Packs.superballTool)
	-- self:RegisterTool("Sword", Prefabs.swordTool, Packs.swordTool)
	self:RegisterTool("Rocket", Prefabs.RocketTool, Packs.RocketTool)
	-- self:RegisterTool("Bomb", Prefabs.bombTool, Packs.bombTool)
	-- self:RegisterTool("Trowel", Prefabs.trowelTool, Packs.trowelTool)
	-- self:RegisterTool("Slingshot", Prefabs.slingshotTool, Packs.slingshotTool)
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

function Crossbow:AddToolsToCharacter(character)
	local player = Players:GetPlayerFromCharacter(character)
	local backpack = player.Backpack

	for _, entry in pairs(self.Tools) do
		if not entry.shouldAdd(character) then continue end

		local tool = entry.prefab:Clone()
		tool.Parent = backpack
		
		self.World:spawn(entry.pack(Components, tool, character))
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

-- function Crossbow:AddToDebris(object, time)
-- 	local typeOf = typeof(object)

-- 	if typeOf == "Instance" then
-- 		self.Manager.Binding:Delay(time, function()
-- 			self.Manager:RemoveRef(object)
-- 			object.Parent = nil
-- 		end)
-- 	elseif typeOf == "table" then
-- 		object.maid:Add(self.Manager.Binding:Delay(time, function()
-- 			self.Manager:RemoveRef(object.ref)
-- 			object.Parent = nil
-- 		end))
-- 	else
-- 		error("Invalid type: " .. typeOf, 2)
-- 	end
	
-- end

-- remove all projectiles & all else required between meta / rep-mode switches
function Crossbow:Reset()

end

function Crossbow:_registerSystems(target)
	local newSystems = {}

	self:ForEachModulescript(function(module)
		if module.name:find(".spec$") then return end

		local source = require(module)
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
	end, target)

	self.Loop:scheduleSystems(newSystems)
end

function Crossbow:ForEachModulescript(handler, folder)
	for _, child in pairs(folder:GetChildren()) do
		if child:IsA("ModuleScript") then
			handler(child)
		elseif child:IsA("Folder") then
			self:ForEachModulescript(handler, child)
		end
	end
end

return Crossbow.new()