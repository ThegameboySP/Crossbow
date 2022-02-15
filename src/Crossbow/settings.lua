local t = require(script.Parent.Parent.Parent.t)
local Matter = require(script.Parent.Parent.Parent.Matter)

local Filters = require(script.Parent.Parent.Utilities.Filters)
local Value = require(script.Parent.Parent.Utilities.Value)
local General = require(script.Parent.Parent.Utilities.General)
local Layers = require(script.Parent.Parent.Utilities.Layers)

local NetMode = require(script.Parent.Parent.Shared.NetMode)
local Assets = script.Parent.Parent.Assets
local Audio = Assets.Audio
local Prefabs = Assets.Prefabs

local function find(instance, name)
	return instance:FindFirstChild(name) or error(("No child named %q under %s"):format(name, instance:GetFullName()), 2)
end

local function mergeToolInherits(tbl)
	return Matter.merge({
		onlyActivateOnPartHit = Value.new(false, t.boolean);
		fireSound = Value.new(nil, t.optional(t.instanceIsA("Sound")));
		pack = Value.new(nil, t.callback);
	}, tbl)
end

return function(crossbow, onInit)
	return General.lockTable("Settings", {
		Superball = General.lockTable("Superball", {
			colorEnabled = Value.new(true, t.boolean);
		});
	
		RocketTool = General.lockTable("RocketTool", mergeToolInherits({
			velocity = Value.new(60, t.number);
			reloadTime = Value.new(7, t.number);
			spawnDistance = Value.new(6, t.number);
	
			prefab = Value.new(Prefabs.Rocket, t.instanceIsA("Part"));
	
			pack = onInit(Value.new(nil, t.callback), function(value)
				value:Set(crossbow.Packs.Rocket)
			end);
		}));
	
		Rocket = General.lockTable("Rocket", {
			velocity = Value.new(60, t.number);
			explosionRadius = Value.new(6, t.number);
			explosionDamage = Value.new(Layers.new({101}), Layers.validator(t.number));
			lifetime = Value.new(15, t.number);
			explodeFilter = Value.new(function(selfPart, part)
				return
					not crossbow:GetProjectile(part)
					and Filters.canCollide(selfPart, part)
			end, t.callback);
		});
	
		Trowel = General.lockTable("Trowel", {
			visualizationEnabled = Value.new(false, t.boolean);
		});
	
		Explosion = General.lockTable("Explosion", {
			damage = Value.new(101, t.number);
			flingBombsEnabled = Value.new(true, t.boolean);
			flingFactorOnSelf = Value.new(0, t.number);
			flingFilter = Value.new(Filters.always, t.callback);
			
			breakJointsFilter = Value.new(Filters.always, t.callback);
		});
	
		Sounds = General.lockTable("Sounds", {
			fireSuperball = Value.new(find(Audio, "SuperballBounce"), t.instanceIsA("Sound"));
			swordLunge = Value.new(find(Audio, "SwordLunge"), t.instanceIsA("Sound"));
			swordEquip = Value.new(find(Audio, "SwordEquip"), t.instanceIsA("Sound"));
			swordSlash = Value.new(find(Audio, "SwordSlash"), t.instanceIsA("Sound"));
			rocketExplode = Value.new(find(Audio, "RocketExplode"), t.instanceIsA("Sound"));
			bombExplode = Value.new(find(Audio, "BombExplodeModern"), t.instanceIsA("Sound"));
			bombTick = Value.new(find(Audio, "BombTick"), t.instanceIsA("Sound"));
			fireSlingshot = Value.new(find(Audio, "SlingshotModern"), t.instanceIsA("Sound"));
			build = Value.new(find(Audio, "TrowelBuild"), t.instanceIsA("Sound"));
		});
	
		Prefabs = General.lockTable("Prefabs", {
			superballTool = Value.new(find(Prefabs, "SuperballTool"), t.instanceIsA("Tool"));
			rocketTool = Value.new(find(Prefabs, "RocketTool"), t.instanceIsA("Tool"));
			bombTool = Value.new(find(Prefabs, "BombTool"), t.instanceIsA("Tool"));
			trowelTool = Value.new(find(Prefabs, "TrowelTool"), t.instanceIsA("Tool"));
			slingshotTool = Value.new(find(Prefabs, "SlingshotTool"), t.instanceIsA("Tool"));
			swordTool = Value.new(find(Prefabs, "SwordTool"), t.instanceIsA("Tool"));
	
			superball = Value.new(find(Prefabs, "Superball"), t.instanceIsA("Tool"));
			rocket = Value.new(find(Prefabs, "Rocket"), t.instanceIsA("Tool"));
			bomb = Value.new(find(Prefabs, "Bomb"), t.instanceIsA("Tool"));
			pellet = Value.new(find(Prefabs, "Pellet"), t.instanceIsA("Tool"));
		});
	
		Rules = General.lockTable("Rules", {
			canDamage = Value.new(function(char1, char2, damageType)
				return 
					(if damageType == "Hit" then char1 ~= char2 else true)
					and char1 and char2 and Filters.isValidCharacter(char1) and Filters.isValidCharacter(char2)
					and not char1:FindFirstChildWhichIsA("ForceField")
					and not char2:FindFirstChildWhichIsA("ForceField")
			end, t.callback);
	
			hitPartFilter = Value.new(Filters.always, t.callback);
		
			raycastFilter = Value.new(function(part)
				return 
					Filters.canCollide(part)
					and not Filters.isLocalCharacter(part)
					and not crossbow:GetProjectile(part)
			end, t.callback);
		
			connectTouched = Value.new(function(part, handler)
				local con = part.Touched:Connect(handler)
				return function()
					con:Disconnect()
				end
			end, t.callback);
		});
	
		netMode = Value.new(NetMode.NetworkOwnership, t.valueOf(NetMode));
	})
end