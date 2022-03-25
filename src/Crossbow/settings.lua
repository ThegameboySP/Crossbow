local t = require(script.Parent.Parent.Parent.t)

local Filters = require(script.Parent.Parent.Utilities.Filters)
local Value = require(script.Parent.Parent.Utilities.Value)
local General = require(script.Parent.Parent.Utilities.General)
local Layers = require(script.Parent.Parent.Utilities.Layers)

local NetMode = require(script.Parent.Parent.Shared.NetMode)
local Assets = script.Parent.Parent.Assets
local Audio = Assets.Audio
local Prefabs = Assets.Prefabs

return function(crossbow, onInit)
	local callbackValidator = function(value)
		local ok, err = t.string(value)
		if not ok then
			return false, err
		end
		
		if not crossbow.Settings.Callbacks[value] then
			return false, string.format("Callback ID %s has no entry", value)
		end

		return true
	end
	
	local packValidator = function(value)
		local ok, err = t.string(value)
		if not ok then
			return false, err
		end
		
		if not crossbow.Packs[value] then
			return false, string.format("Pack ID %s has no entry", value)
		end

		return true
	end

	return General.lockTable("Settings", {
		Callbacks = {
			defaultCanDamage = function(victim, attacker, damageType)
				return 
					(if damageType == "Hit" or damageType == "Melee" then victim ~= attacker else true)
					and victim and Filters.isValidCharacter(victim) and (not attacker or Filters.isValidCharacter(attacker))
					and not victim:FindFirstChildWhichIsA("ForceField")
					and (not attacker or not attacker:FindFirstChildWhichIsA("ForceField"))
			end;
			defaultRaycastFilter = function(part)
				return 
					Filters.canCollide(part)
					and not Filters.isLocalCharacter(part)
					and not crossbow:GetProjectile(part)
			end;
			getPartPosAtTip = function(part)
				return (part.CFrame * CFrame.new(-Vector3.zAxis * part.Size.Z / 2)).Position
			end;
			rocketExplodeFilter = function(part)
				return
					not crossbow:GetProjectile(part)
					and Filters.canCollide(part)
			end;
			always = Filters.always;
			never = Filters.never;
		};

		RocketTool = General.lockTable("RocketTool", {
			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
			velocity = Value.new(60, t.number);
			reloadTime = Value.new(0, t.number);
			spawnDistance = Value.new(6, t.number);
	
			prefab = Value.new(Prefabs.Rocket, t.instanceIsA("Part"));
	
			fireSound = Value.new(nil, Value.is);
			pack = Value.new("Rocket", packValidator);
		});

		Rocket = General.lockTable("Rocket", {
			velocity = Value.new(60, t.number);
			explosionRadius = Value.new(4, t.number);
			explosionDamage = Value.new(Layers.new({101}), Layers.validator(t.number));
			lifetime = Value.new(15, t.number);
			explodeFilter = Value.new("rocketExplodeFilter", callbackValidator);
		});

		SuperballTool = General.lockTable("SuperballTool", {
			fireSound = onInit(Value.new(nil, Value.is), function(value)
				value:Set(crossbow.Settings.Sounds.superballBounce)
			end);
			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
			velocity = Value.new(200, t.number);
			reloadTime = Value.new(2, t.number);
			spawnDistance = Value.new(6, t.number);
	
			prefab = Value.new(Prefabs.Superball, t.instanceIsA("Part"));
	
			pack = Value.new("Superball", packValidator);
		});

		Superball = General.lockTable("Superball", {
			damageAmount = Value.new(1, t.number);
			damageCooldown = Value.new(1, t.number);
			damage = Value.new(55, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);

			lifetime = Value.new(10, t.number);
			maxBounces = Value.new(8, t.number);
			bouncePauseTime = Value.new(0.1, t.number);

			hitFilter = Value.new(function(part)
				return Filters.canCollide(part)
			end, t.callback);

			colorEnabled = Value.new(true, t.boolean);
		});

		BombTool = General.lockTable("BombTool", {
			fireSound = Value.new(nil, Value.is);
			reloadTime = Value.new(0, t.number);
			spawnDistance = Value.new(2, t.number);
	
			prefab = Value.new(Prefabs.Bomb, t.instanceIsA("Part"));
	
			pack = Value.new("Bomb", packValidator);
		});

		Bomb = General.lockTable("Bomb", {
			damage = Value.new(101, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);
			explosionRadius = Value.new(12, t.number);

			startingInterval = Value.new(0.4, t.number);
			multiplier = Value.new(0.9, t.number);

			tickColors = Value.new({
				Color3.fromRGB(170, 0, 0),
				Color3.fromRGB(27, 42, 53),
			}, t.array(t.Color3));
		});

		SwordTool = General.lockTable("SwordTool", {
			idleDamage = Value.new(10, t.number);
			slashDamage = Value.new(20, t.number);
			lungeDamage = Value.new(35, t.number);
			
			floatAmount = Value.new(5000, t.number);
			floatHeight = Value.new(13, t.number);

			damageCooldown = Value.new(0.2, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);
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
			canDamage = Value.new("defaultCanDamage", callbackValidator);
			hitPartFilter = Value.new(Filters.always, t.callback);
			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
		});
	})
end