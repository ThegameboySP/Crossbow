local t = require(script.Parent.Parent.Parent.t)

local Filters = require(script.Parent.Parent.Utilities.Filters)
local Value = require(script.Parent.Parent.Utilities.Value)
local General = require(script.Parent.Parent.Utilities.General)
local Layers = require(script.Parent.Parent.Utilities.Layers)

local NetMode = require(script.Parent.Parent.Shared.NetMode)
local Assets = script.Parent.Parent.Assets
local Audio = Assets.Audio
local Prefabs = Assets.Prefabs

return function(crossbow)
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

	local optionalSound = t.optional(t.instanceIsA("Sound"))
	local isTool = t.instanceIsA("Tool")
	
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
			trowelRaycastFilter = function(part)
				return
					Filters.canCollide(part)
					and not Filters.isLocalCharacter(part)
			end;
			getPartPosAtTip = function(part)
				return (part.CFrame * CFrame.new(-Vector3.zAxis * part.Size.Z / 2)).Position
			end;
			rocketExplodeFilter = function(part)
				return
					not crossbow:GetProjectile(part)
					and Filters.canCollide(part)
			end;
			defaultTrowelShouldWeld = function(part, normalId)
				if General.getCharacter(part) then
					return false
				end
	
				local surface = part[normalId.Name .. "Surface"]
		
				return
					surface == Enum.SurfaceType.Studs
					or surface == Enum.SurfaceType.Weld
					or surface == Enum.SurfaceType.Glue
			end;
			defaultRicochetFilter = function(part)
				return Filters.canCollide(part, "Crossbow_Projectile")
			end;
			always = Filters.always;
			never = Filters.never;
		};

		RocketTool = General.lockTable("RocketTool", {
			fireSound = Value.new(nil, optionalSound);

			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
			velocity = Value.new(60, t.number);
			reloadTime = Value.new(0, t.number);
			spawnDistance = Value.new(6, t.number);
	
			prefab = Value.new(Prefabs.Rocket, t.instanceIsA("Part"));
	
			pack = Value.new("Rocket", packValidator);
		});

		Rocket = General.lockTable("Rocket", {
			explodeSound = Value.new(Audio.RocketExplode, optionalSound);

			velocity = Value.new(60, t.number);
			explosionRadius = Value.new(4, t.number);
			explosionDamage = Value.new(Layers.new({101}), Layers.validator(t.number));
			lifetime = Value.new(15, t.number);
			explodeFilter = Value.new("rocketExplodeFilter", callbackValidator);
		});

		SuperballTool = General.lockTable("SuperballTool", {
			fireSound = Value.new(Audio.SuperballBounce, optionalSound);

			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
			velocity = Value.new(200, t.number);
			reloadTime = Value.new(2, t.number);
			spawnDistance = Value.new(4, t.number);
	
			prefab = Value.new(Prefabs.Superball, t.instanceIsA("Part"));
	
			pack = Value.new("Superball", packValidator);
		});

		Superball = General.lockTable("Superball", {
			bounceSound = Value.new(Audio.SuperballBounce, optionalSound);

			damageAmount = Value.new(1, t.number);
			damageCooldown = Value.new(1/30, t.number);
			damage = Value.new(55, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);

			lifetime = Value.new(10, t.number);
			maxBounces = Value.new(8, t.number);
			bouncePauseTime = Value.new(0.1, t.number);

			ricochetFilter = Value.new("defaultRicochetFilter", t.callbackValidator);

			colorEnabled = Value.new(true, t.boolean);
		});

		BombTool = General.lockTable("BombTool", {
			fireSound = Value.new(nil, optionalSound);

			reloadTime = Value.new(4, t.number);
			spawnDistance = Value.new(4, t.number);
	
			prefab = Value.new(Prefabs.Bomb, t.instanceIsA("Part"));
	
			pack = Value.new("Bomb", packValidator);
		});

		Bomb = General.lockTable("Bomb", {
			explodeSound = Value.new(Audio.BombExplodeModern, optionalSound);
			tickSound = Value.new(Audio.BombTick, optionalSound);

			damage = Value.new(101, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);
			explosionRadius = Value.new(12, t.number);

			startingInterval = Value.new(0.4, t.number);
			multiplier = Value.new(0.9, t.number);

			tickColors = Value.new({
				Color3.fromRGB(170, 0, 0),
				Color3.fromRGB(27, 42, 53)
			}, t.array(t.Color3));
		});

		SwordTool = General.lockTable("SwordTool", {
			equipSound = Value.new(Audio.SwordEquip, optionalSound);
			slashSound = Value.new(Audio.SwordSlash, optionalSound);
			lungeSound = Value.new(Audio.SwordLunge, optionalSound);

			idleDamage = Value.new(10, t.number);
			slashDamage = Value.new(20, t.number);
			lungeDamage = Value.new(35, t.number);
			
			floatAmount = Value.new(5000, t.number);
			floatHeight = Value.new(13, t.number);

			damageCooldown = Value.new(0.2, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);
		});

		TrowelTool = General.lockTable("TrowelTool", {
			equipSound = Value.new(nil, optionalSound);
			buildSound = Value.new(Audio.TrowelBuild, optionalSound);

			raycastFilter = Value.new("trowelRaycastFilter", callbackValidator);
			reloadTime = Value.new(0, t.number);
	
			prefab = Value.new(Prefabs.TrowelBrick, t.instanceIsA("Part"));
			pack = Value.new("TrowelWall", packValidator);

			rotationStep = Value.new(90, t.number);
			bricksPerRow = Value.new(3, t.number);
			bricksPerColumn = Value.new(4, t.number);
			brickSpeed = Value.new(0.04, t.number);
			lifetime = Value.new(25, t.number);
			shouldWeld = Value.new("defaultTrowelShouldWeld", callbackValidator);

			visualizationEnabled = Value.new(false, t.boolean);
		});

		SlingshotTool = General.lockTable("SlingshotTool", {
			fireSound = Value.new(Audio.SlingshotModern, optionalSound);

			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
			velocity = Value.new(85, t.number);
			reloadTime = Value.new(0.2, t.number);
			spawnDistance = Value.new(3, t.number);
	
			prefab = Value.new(Prefabs.SlingshotPellet, t.instanceIsA("Part"));
	
			pack = Value.new("SlingshotPellet", packValidator);
		});

		SlingshotPellet = General.lockTable("SlingshotPellet", {
			damageAmount = Value.new(1, t.number);
			damage = Value.new(16, t.number);
			damageCooldown = Value.new(0.5, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);

			maxBounces = Value.new(3, t.number);
			bouncePauseTime = Value.new(0.1, t.number);

			lifetime = Value.new(7, t.number);
		});

		PaintballTool = General.lockTable("PaintballTool", {
			fireSound = Value.new(Audio.PaintballFire, optionalSound);

			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
			velocity = Value.new(200, t.number);
			reloadTime = Value.new(0.5, t.number);
			spawnDistance = Value.new(3, t.number);
	
			prefab = Value.new(Prefabs.PaintballPellet, t.instanceIsA("Part"));
	
			pack = Value.new("PaintballPellet", packValidator);
		});

		PaintballPellet = General.lockTable("PaintballPellet", {
			damageAmount = Value.new(1, t.number);
			damage = Value.new(15, t.number);
			damageCooldown = Value.new(0, t.number);
			canDamageFilter = Value.new("defaultCanDamage", callbackValidator);

			ricochetFilter = Value.new("defaultRicochetFilter", callbackValidator);
			ricochetDebounce = Value.new(0, t.number);

			antigravity = Value.new(0.834, t.number);

			lifetime = Value.new(10, t.number);
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

		Sounds = General.lockTable("Sounds", {
			fireSlingshot = Value.new(Audio.SlingshotModern, optionalSound);
			successfulHit = Value.new(Audio.HitTyzone, optionalSound);
		});
	
		Prefabs = General.lockTable("Prefabs", {
			superballTool = Value.new(Prefabs.SuperballTool, isTool);
			rocketTool = Value.new(Prefabs.RocketTool, isTool);
			bombTool = Value.new(Prefabs.BombTool, isTool);
			trowelTool = Value.new(Prefabs.TrowelTool, isTool);
			slingshotTool = Value.new(Prefabs.SlingshotTool, isTool);
			swordTool = Value.new(Prefabs.SwordTool, isTool);
	
			superball = Value.new(Prefabs.Superball, isTool);
			rocket = Value.new(Prefabs.Rocket, isTool);
			bomb = Value.new(Prefabs.Bomb, isTool);
			slingshotPellet = Value.new(Prefabs.SlingshotPellet, isTool);
		});
	
		Rules = General.lockTable("Rules", {
			canDamage = Value.new("defaultCanDamage", callbackValidator);
			hitPartFilter = Value.new(Filters.always, t.callback);
			raycastFilter = Value.new("defaultRaycastFilter", callbackValidator);
		});
	})
end