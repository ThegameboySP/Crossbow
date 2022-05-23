local Components = require(script.Parent.Parent.Components)

local function generateToolPack(crossbow)
	return function(generate)
		return function(character, params)
			params = params or {}
			local userComponents = {generate(params, character)}
			local toolComponent = userComponents[1]

			local componentName = toolComponent:getDefinition().componentName
			local settings = crossbow.Settings[componentName]

			return
				Components.Tool({
					character = character;
					componentName = componentName;

					reloadTime = rawget(settings, "reloadTime") and (params.reloadTime or settings.reloadTime:Get()) or 0;
					equipSound = rawget(settings, "equipSound") and settings.equipSound:Get();
					fireSound = rawget(settings, "fireSound") and settings.fireSound:Get();
				}),
				unpack(userComponents)
		end
	end
end

local function generateProjectilePack()
	return function(generate)
		return function(spawnerId, character, velocity, cframe, params)
			local userComponents = {generate(params or {}, spawnerId, character, velocity, cframe)}
			local projectileComponent = userComponents[1]

			return
				Components.Projectile({
					spawnerId = spawnerId;
					componentName = projectileComponent:getDefinition().componentName;
					character = character;
				}),
				Components.Transform({
					cframe = cframe
				}),
				unpack(userComponents)
		end
	end
end

return function(crossbow, onInit)
	local toolPack = generateToolPack(crossbow)
	local projectilePack = generateProjectilePack()
	
	local settings
	onInit(function()
		settings = crossbow.Settings
	end)

	return {
		RocketTool = toolPack(function()
			return
				Components.RocketTool({
					raycastFilter = settings.RocketTool.raycastFilter:Get();
					velocity = settings.RocketTool.velocity:Get();
					spawnDistance = settings.RocketTool.spawnDistance:Get();
					prefab = settings.RocketTool.prefab:Get();
					pack = settings.RocketTool.pack:Get();
				})
		end);
		Rocket = projectilePack(function(params, _, _, velocity, cframe)
			return
				Components.Rocket(),
				Components.FixedVelocity({
					velocity = cframe.LookVector * velocity;
				}),
				Components.ExplodeOnTouch({
					damage = params.explosionDamage or settings.Rocket.explosionDamage:Get():get();
					radius = params.explosionRadius or settings.Rocket.explosionRadius:Get();
					filter = params.explodeFilter or settings.Rocket.explodeFilter:Get();
					transform = "getPartPosAtTip";
					explodeSound = params.explodeSound or settings.Rocket.explodeSound:Get();
				}),
				Components.Lifetime({
					duration = params.lifetime or settings.Rocket.lifetime:Get();
					timestamp = crossbow.Params.currentFrame;
				})
		end);
		SuperballTool = toolPack(function()
			return
				Components.SuperballTool({
					raycastFilter = settings.SuperballTool.raycastFilter:Get();
					velocity = settings.SuperballTool.velocity:Get();
					spawnDistance = settings.SuperballTool.spawnDistance:Get();
					prefab = settings.SuperballTool.prefab:Get();
					pack = settings.SuperballTool.pack:Get();
				})
		end);
		Superball = projectilePack(function(params, _, _, velocity, cframe)
			return
				Components.Superball(),
				Components.Velocity({
					velocity = cframe.LookVector * velocity;
				}),
				Components.Ricochets({
					damageMultiplier = 0.5;
					debounce = settings.Superball.bouncePauseTime:Get();
					filter = settings.Superball.ricochetFilter:Get();
					maxRicochets = settings.Superball.maxBounces:Get();
					ricochets = 0;
					timestamp = 0;
				}),
				Components.Damage({
					filter = params.canDamageFilter or settings.Superball.canDamageFilter:Get();
					amount = params.damageAmount or settings.Superball.damageAmount:Get();
					cooldown = params.damageCooldown or settings.Superball.damageCooldown:Get();
					damage = params.damage or settings.Superball.damage:Get();
					damageType = "Hit";
					removeOnNoDamage = true;
				}),
				Components.Lifetime({
					duration = params.lifetime or settings.Superball.lifetime:Get();
					timestamp = crossbow.Params.currentFrame;
				})
		end);
		BombTool = toolPack(function()
			return
				Components.BombTool({
					spawnDistance = settings.BombTool.spawnDistance:Get();
					prefab = settings.BombTool.prefab:Get();
					pack = settings.BombTool.pack:Get();
				})
		end);
		Bomb = projectilePack(function(params)
			return
				Components.Bomb(),
				Components.ExplodeCountdown({
					tickColors = params.tickColors or settings.Bomb.tickColors:Get();
					startingInterval = params.startingInterval or settings.Bomb.startingInterval:Get();
					multiplier = params.multiplier or settings.Bomb.multiplier:Get();
					radius = params.explosionRadius or settings.Bomb.explosionRadius:Get();
					explodeSound = params.explodeSound or settings.Bomb.explodeSound:Get();
					tickSound = params.tickSound or settings.Bomb.tickSound:Get();
				})
		end);
		SwordTool = toolPack(function(params)
			return
				Components.SwordTool({
					state = "Idle";

					slashSound = params.slashSound or settings.SwordTool.slashSound:Get();
					lungeSound = params.lungeSound or settings.SwordTool.lungeSound:Get();

					idleDamage = params.idleDamage or settings.SwordTool.idleDamage:Get();
					slashDamage = params.slashDamage or settings.SwordTool.slashDamage:Get();
					lungeDamage = params.lungeDamage or settings.SwordTool.lungeDamage:Get();

					floatAmount = params.floatAmount or settings.SwordTool.floatAmount:Get();
					floatHeight = params.floatHeight or settings.SwordTool.floatHeight:Get();
				}),
				Components.Damage({
					damage = params.idleDamage or settings.SwordTool.idleDamage:Get();
					cooldown = params.damageCooldown or settings.SwordTool.damageCooldown:Get();
					filter = params.damageFilter or settings.SwordTool.canDamageFilter:Get();
					damageType = "Melee";
				})
		end);
		TrowelTool = toolPack(function()
			return
				Components.TrowelTool({
					rotation = 0;
					isLocked = false;
					buildSound = settings.TrowelTool.buildSound:Get();
					
					raycastFilter = settings.TrowelTool.raycastFilter:Get();
					shouldWeld = settings.TrowelTool.shouldWeld:Get();
					prefab = settings.TrowelTool.prefab:Get();
					pack = settings.TrowelTool.pack:Get();

					rotationStep = settings.TrowelTool.rotationStep:Get();
					bricksPerRow = settings.TrowelTool.bricksPerRow:Get();
					bricksPerColumn = settings.TrowelTool.bricksPerColumn:Get();
					brickSpeed = settings.TrowelTool.brickSpeed:Get();
				})
		end);
		TrowelWall = function(id, pos, part, normal, dir)
			return
				Components.TrowelWall({
					normal = normal;
					part = part;
					spawnerId = id;
				}),
				Components.TrowelBuilding(),
				Components.Transform({
					cframe = CFrame.lookAt(pos, pos - dir);
				})
		end;
		SlingshotTool = toolPack(function()
			return
				Components.SlingshotTool({
					raycastFilter = settings.SlingshotTool.raycastFilter:Get();
					velocity = settings.SlingshotTool.velocity:Get();
					spawnDistance = settings.SlingshotTool.spawnDistance:Get();
					prefab = settings.SlingshotTool.prefab:Get();
					pack = settings.SlingshotTool.pack:Get();
				})
		end),
		SlingshotPellet = projectilePack(function(_, _, _, velocity, cframe)
			return
				Components.SlingshotPellet(),
				Components.Damage({
					amount = settings.SlingshotPellet.damageAmount:Get();
					damage = settings.SlingshotPellet.damage:Get();
					filter = settings.SlingshotPellet.canDamageFilter:Get();
					damageType = "Hit";
					removeOnNoDamage = true;
				}),
				Components.Ricochets({
					damageMultiplier = 0.5;
					debounce = settings.SlingshotPellet.bouncePauseTime:Get();
					filter = "defaultRicochetFilter";
					maxRicochets = settings.SlingshotPellet.maxBounces:Get();
					ricochets = 0;
					timestamp = 0;
				}),
				Components.Velocity({
					velocity = cframe.LookVector * velocity;
				}),
				Components.Lifetime({
					duration = settings.SlingshotPellet.lifetime:Get();
					timestamp = crossbow.Params.currentFrame;
				})
		end);
		PaintballTool = toolPack(function()
			return
				Components.PaintballTool({
					raycastFilter = settings.PaintballTool.raycastFilter:Get();
					velocity = settings.PaintballTool.velocity:Get();
					spawnDistance = settings.PaintballTool.spawnDistance:Get();
					prefab = settings.PaintballTool.prefab:Get();
					pack = settings.PaintballTool.pack:Get();
				})
		end);
		PaintballPellet = projectilePack(function(_, _, _, velocity, cframe)
			return
				Components.PaintballPellet(),
				Components.Damage({
					amount = settings.PaintballPellet.damageAmount:Get();
					damage = settings.PaintballPellet.damage:Get();
					cooldown = settings.PaintballPellet.damageCooldown:Get();
					filter = settings.PaintballPellet.canDamageFilter:Get();
					damageType = "Hit";
					removeOnNoDamage = true;
				}),
				Components.Ricochets({
					damageMultiplier = 1;
					debounce = settings.PaintballPellet.ricochetDebounce:Get();
					filter = settings.PaintballPellet.ricochetFilter:Get();
					maxRicochets = 1;
					ricochets = 0;
					timestamp = 0;
				}),
				Components.Velocity({
					velocity = cframe.LookVector * velocity;
				}),
				Components.Antigravity({
					factor = settings.PaintballPellet.antigravity:Get();
				}),
				Components.Lifetime({
					duration = settings.PaintballPellet.lifetime:Get();
					timestamp = crossbow.Params.currentFrame;
				})
		end);
		Explosion = function(damage, filter)
			return
				Components.Explosion(),
				Components.Lifetime({
					duration = 0;
					timestamp = crossbow.Params.currentFrame;
				}),
				Components.Damage({
					damage = damage or settings.Explosion.damage:Get();
					filter = filter or settings.Explosion.damageFilter:Get();
					damageType = "Explosion";
				})
		end;
	}
end
