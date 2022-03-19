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

local function mergeToolInherits(tbl)
	return Matter.merge({
		onlyActivateOnPartHit = Value.new(false, t.boolean);
		fireSound = Value.new(nil, t.optional(t.instanceIsA("Sound")));
		pack = Value.new(nil, t.callback);
	}, tbl)
end

return function(crossbow, onInit)
	local function defaultRaycastFilter(part)
		return 
			Filters.canCollide(part)
			and not Filters.isLocalCharacter(part)
			and not crossbow:GetProjectile(part)
	end

	local function defaultCanDamage(char1, char2, damageType)
		return 
			(if damageType == "Hit" then char1 ~= char2 else true)
			and char1 and char2 and Filters.isValidCharacter(char1) and Filters.isValidCharacter(char2)
			and not char1:FindFirstChildWhichIsA("ForceField")
			and not char2:FindFirstChildWhichIsA("ForceField")
	end
	
	return General.lockTable("Settings", {	
		RocketTool = General.lockTable("RocketTool", mergeToolInherits({
			raycastFilter = Value.new(defaultRaycastFilter, t.callback);
			velocity = Value.new(60, t.number);
			reloadTime = Value.new(0, t.number);
			spawnDistance = Value.new(6, t.number);
	
			prefab = Value.new(Prefabs.Rocket, t.instanceIsA("Part"));
	
			pack = onInit(Value.new(nil, t.callback), function(value)
				value:Set(crossbow.Packs.Rocket)
			end);
		}));

		Rocket = General.lockTable("Rocket", {
			velocity = Value.new(60, t.number);
			explosionRadius = Value.new(4, t.number);
			explosionDamage = Value.new(Layers.new({101}), Layers.validator(t.number));
			lifetime = Value.new(15, t.number);
			explodeFilter = Value.new(function(part)
				return
					not crossbow:GetProjectile(part)
					and Filters.canCollide(part)
			end, t.callback);
		});

		SuperballTool = General.lockTable("SuperballTool", mergeToolInherits({
			fireSound = onInit(Value.new(nil, Value.is), function(value)
				value:Set(crossbow.Settings.Sounds.superballBounce)
			end);
			raycastFilter = Value.new(defaultRaycastFilter, t.callback);
			velocity = Value.new(200, t.number);
			reloadTime = Value.new(2, t.number);
			spawnDistance = Value.new(6, t.number);
	
			prefab = Value.new(Prefabs.Superball, t.instanceIsA("Part"));
	
			pack = onInit(Value.new(nil, t.callback), function(value)
				value:Set(crossbow.Packs.Superball)
			end);
		}));

		Superball = General.lockTable("Superball", {
			damageAmount = Value.new(1, t.number);
			damageCooldown = Value.new(1, t.number);
			damage = Value.new(55, t.number);
			canDamageFilter = Value.new(defaultCanDamage, t.callback);

			lifetime = Value.new(10, t.number);
			maxBounces = Value.new(8, t.number);
			bouncePauseTime = Value.new(0.1, t.number);

			hitFilter = Value.new(function(part)
				return Filters.canCollide(part)
			end, t.callback);

			colorEnabled = Value.new(true, t.boolean);
		});

		BombTool = General.lockTable("BombTool", mergeToolInherits({
			reloadTime = Value.new(0, t.number);
			spawnDistance = Value.new(2, t.number);
	
			prefab = Value.new(Prefabs.Bomb, t.instanceIsA("Part"));
	
			pack = onInit(Value.new(nil, t.callback), function(value)
				value:Set(crossbow.Packs.Bomb)
			end);
		}));

		Bomb = General.lockTable("Bomb", {
			damage = Value.new(101, t.number);
			canDamageFilter = Value.new(defaultCanDamage, t.callback);
			explosionRadius = Value.new(12, t.number);

			startingInterval = Value.new(0.4, t.number);
			multiplier = Value.new(0.9, t.number);

			tickColors = Value.new({
				Color3.fromRGB(170, 0, 0),
				Color3.fromRGB(27, 42, 53),
			}, t.array(t.Color3));
		});

		Trowel = General.lockTable("Trowel", {
			visualizationEnabled = Value.new(false, t.boolean);
		});
	
		Network = General.lockTable("Network", {
			netMode = Value.new("Extrapolation", t.valueOf(NetMode));
			extrapolationFrequency = Value.new(1/6, t.number);
		});

		Systems = General.lockTable("Systems", {
			
		});

		Interfacing = General.lockTable("Interfacing", {
			getTouchedSignal = Value.new(function(part)
				return part.Touched
			end, t.callback);

			dealDamage = Value.new(function(humanoid, damage, _, canKill)
				if canKill then
					humanoid.Health -= damage
				else
					humanoid.Health = math.max(0.01, humanoid.Health - damage)
				end
			end)
		});

		Explosion = General.lockTable("Explosion", {
			damage = Value.new(101, t.number);
			flingBombsEnabled = Value.new(true, t.boolean);
			flingFactorOnSelf = Value.new(0, t.number);
			flingFilter = Value.new(Filters.always, t.callback);
			
			breakJointsFilter = Value.new(Filters.always, t.callback);
		});
	
		ThrottledSounds = onInit({}, function(throttled)
			throttled[crossbow.Settings.Sounds.swordEquip] = 1
			throttled[crossbow.Settings.Sounds.superballBounce] = 1
		end);

		Sounds = General.lockTable("Sounds", {
			superballBounce = Value.new(Audio.SuperballBounce, t.instanceIsA("Sound"));
			swordLunge = Value.new(Audio.SwordLunge, t.instanceIsA("Sound"));
			swordEquip = Value.new(Audio.SwordEquip, t.instanceIsA("Sound"));
			swordSlash = Value.new(Audio.SwordSlash, t.instanceIsA("Sound"));
			rocketExplode = Value.new(Audio.RocketExplode, t.instanceIsA("Sound"));
			bombExplode = Value.new(Audio.BombExplodeModern, t.instanceIsA("Sound"));
			bombTick = Value.new(Audio.BombTick, t.instanceIsA("Sound"));
			fireSlingshot = Value.new(Audio.SlingshotModern, t.instanceIsA("Sound"));
			build = Value.new(Audio.TrowelBuild, t.instanceIsA("Sound"));
			successfulHit = Value.new(Audio.HitTyzone, t.instanceIsA("Sound"));
		});
	
		Prefabs = General.lockTable("Prefabs", {
			superballTool = Value.new(Prefabs.SuperballTool, t.instanceIsA("Tool"));
			rocketTool = Value.new(Prefabs.RocketTool, t.instanceIsA("Tool"));
			bombTool = Value.new(Prefabs.BombTool, t.instanceIsA("Tool"));
			trowelTool = Value.new(Prefabs.TrowelTool, t.instanceIsA("Tool"));
			slingshotTool = Value.new(Prefabs.SlingshotTool, t.instanceIsA("Tool"));
			swordTool = Value.new(Prefabs.SwordTool, t.instanceIsA("Tool"));
	
			superball = Value.new(Prefabs.Superball, t.instanceIsA("Tool"));
			rocket = Value.new(Prefabs.Rocket, t.instanceIsA("Tool"));
			bomb = Value.new(Prefabs.Bomb, t.instanceIsA("Tool"));
			pellet = Value.new(Prefabs.Pellet, t.instanceIsA("Tool"));
		});
	
		Rules = General.lockTable("Rules", {
			canDamage = Value.new(defaultCanDamage, t.callback);
			hitPartFilter = Value.new(Filters.always, t.callback);
			raycastFilter = Value.new(defaultRaycastFilter, t.callback);
		});
	})
end