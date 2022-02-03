local t = require(script.Parent.Parent.Parent.Vendor.t)

local Filters = require(script.Parent.Parent.Utilities.Filters)
local Value = require(script.Parent.Parent.Utilities.Value)
local General = require(script.Parent.Parent.Utilities.General)

local NetMode = require(script.Parent.NetMode)
local Assets = script.Parent.Parent.Assets
local Sounds = Assets.Sounds
local Prefabs = Assets.Prefabs

local function find(instance, name)
	return instance:FindFirstChild(name) or error(("No child named %s under %s"):format(name, instance:GetFullName()))
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
		FireSuperball = Value.new(find(Sounds, "SuperballBounce"), t.instanceIsA("Sound"));
		SwordLunge = Value.new(find(Sounds, "SwordLunge"), t.instanceIsA("Sound"));
		SwordEquip = Value.new(find(Sounds, "SwordEquip"), t.instanceIsA("Sound"));
		SwordSlash = Value.new(find(Sounds, "SwordSlash"), t.instanceIsA("Sound"));
		RocketExplode = Value.new(find(Sounds, "RocketExplode"), t.instanceIsA("Sound"));
		BombExplode = Value.new(find(Sounds, "BombExplodeModern"), t.instanceIsA("Sound"));
		BombTick = Value.new(find(Sounds, "BombTick"), t.instanceIsA("Sound"));
		FireSlingshot = Value.new(find(Sounds, "SlingshotModern"), t.instanceIsA("Sound"));
		Build = Value.new(find(Sounds, "TrowelBuild"), t.instanceIsA("Sound"));
	});

	Prefabs = General.lockTable("Prefabs", {
		Superball = find(Prefabs, "Superball");
		Rocket = find(Prefabs, "Rocket");
		Bomb = find(Prefabs, "Bomb");
		Trowel = find(Prefabs, "TrowelBrick");
		Slingshot = find(Prefabs, "Slingshot");
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