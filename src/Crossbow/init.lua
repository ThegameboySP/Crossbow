local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Prefabs = script.Parent.Assets.Prefabs

local Matter = require(script.Parent.Parent.Matter)
local Definitions = require(script.Parent.Shared.Definitions)
local Filters = require(script.Parent.Utilities.Filters)

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
		local soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = "CrossbowSounds"
		soundGroup.Parent = SoundService
	end
end

function Crossbow:RegisterDefaultTools()
	-- self:RegisterTool("Superball", Prefabs.superballTool, Packs.superballTool)
	-- self:RegisterTool("Sword", Prefabs.swordTool, Packs.swordTool)
	self:RegisterTool("Rocket", Prefabs.RocketTool, self.Packs.RocketTool)
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
		
		self.World:spawn(entry.pack(tool, character))
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