local t = require(script.Parent.Parent.Parent.t)

local Filters = require(script.Parent.Parent.Utilities.Filters)
local Value = require(script.Parent.Parent.Utilities.Value)
local General = require(script.Parent.Parent.Utilities.General)

local NetMode = require(script.Parent.NetMode)
local Assets = script.Parent.Parent.Assets
local Audio = Assets.Audio
local Prefabs = Assets.Prefabs

local function find(instance, name)
	return instance:FindFirstChild(name) or error(("No child named %q under %s"):format(name, instance:GetFullName()), 2)
end

return General.lockTable("Configuration", {
	Superball = General.lockTable("Superball", {
		ColorEnabled = Value.new(true, t.boolean);
	});

	Trowel = General.lockTable("Trowel", {
		VisualizationEnabled = Value.new(false, t.boolean);
	});

	Explosion = General.lockTable("Explosion", {
		Damage = Value.new(101, t.number);
		FlingBombsEnabled = Value.new(true, t.boolean);
		FlingFactorOnSelf = Value.new(0, t.number);
		FlingFilter = Filters.always;
		
		BreakJointsFilter = Filters.always;
	});

	Sounds = General.lockTable("Sounds", {
		FireSuperball = Value.new(find(Audio, "SuperballBounce"), t.instanceIsA("Sound"));
		SwordLunge = Value.new(find(Audio, "SwordLunge"), t.instanceIsA("Sound"));
		SwordEquip = Value.new(find(Audio, "SwordEquip"), t.instanceIsA("Sound"));
		SwordSlash = Value.new(find(Audio, "SwordSlash"), t.instanceIsA("Sound"));
		RocketExplode = Value.new(find(Audio, "RocketExplode"), t.instanceIsA("Sound"));
		BombExplode = Value.new(find(Audio, "BombExplodeModern"), t.instanceIsA("Sound"));
		BombTick = Value.new(find(Audio, "BombTick"), t.instanceIsA("Sound"));
		FireSlingshot = Value.new(find(Audio, "SlingshotModern"), t.instanceIsA("Sound"));
		Build = Value.new(find(Audio, "TrowelBuild"), t.instanceIsA("Sound"));
	});

	Prefabs = General.lockTable("Prefabs", {
		SuperballTool = find(Prefabs, "SuperballTool");
		RocketTool = find(Prefabs, "RocketTool");
		BombTool = find(Prefabs, "BombTool");
		TrowelTool = find(Prefabs, "TrowelTool");
		SlingshotTool = find(Prefabs, "SlingshotTool");
		SwordTool = find(Prefabs, "SwordTool");

		Superball = find(Prefabs, "Superball");
		Rocket = find(Prefabs, "Rocket");
		Bomb = find(Prefabs, "Bomb");
		Pellet = find(Prefabs, "Pellet");
	});

	Rules = General.lockTable("Rules", {
		CanDamage = function(char1, char2, damageType)
			return 
				(if damageType == "Hit" then char1 ~= char2 else true)
				and char1 and char2 and Filters.isValidCharacter(char1) and Filters.isValidCharacter(char2)
				and not char1:FindFirstChildWhichIsA("ForceField")
				and not char2:FindFirstChildWhichIsA("ForceField")
		end;

		HitPartFilter = Filters.always;
	
		RaycastFilter = function(part)
			return 
				Filters.canCollide(part)
				and not Filters.isLocalCharacter(part)
				and not Filters.isProjectile(part)
		end;
	
		ConnectTouched = function(part, handler)
			local con = part.Touched:Connect(handler)
			return function()
				con:Disconnect()
			end
		end;
	});

	NetMode = Value.new(NetMode.NetworkOwnership, t.valueOf(NetMode));
	
})