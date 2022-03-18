local function generateToolPack(crossbow)
	return function(generate)
		return function(character, params)
			local components = crossbow.Components
			local userComponents = {generate(params or {}, character)}
			local toolComponent = userComponents[1]

			return
				components.Tool({
					character = character;
					componentName = toolComponent:getDefinition().componentName;
				}),
				unpack(userComponents)
		end
	end
end

local function generateProjectilePack(crossbow)
	return function(generate)
		return function(spawnerId, character, velocity, cframe, params)
			local components = crossbow.Components
			local userComponents = {generate(params or {}, spawnerId, character, velocity, cframe)}
			local projectileComponent = userComponents[1]

			return
				components.Projectile({
					spawnerId = spawnerId;
					componentName = projectileComponent:getDefinition().componentName;
					character = character;
				}),
				components.Transform({
					cframe = cframe
				}),
				unpack(userComponents)
		end
	end
end

local function bind(crossbow, name)
	return function()
		return crossbow.Components[name]()
	end
end

return function(crossbow, onInit)
	local toolPack = generateToolPack(crossbow)
	local projectilePack = generateProjectilePack(crossbow)
	
	local components
	local settings
	onInit(function()
		components = crossbow.Components
		settings = crossbow.Settings
	end)

	return {
		RocketTool = toolPack(bind(crossbow, "RocketTool"));
		Rocket = projectilePack(function(params, _, _, velocity, cframe)
			return
				components.Rocket(),
				components.FixedVelocity({
					velocity = cframe.LookVector * velocity;
				}),
				components.ExplodeOnTouch({
					damage = params.explosionDamage or settings.Rocket.explosionDamage:Get():get();
					radius = params.explosionRadius or settings.Rocket.explosionRadius:Get();
					filter = params.explodeFilter or settings.Rocket.explodeFilter:Get();
					transform = function(part)
						return (part.CFrame * CFrame.new(-Vector3.zAxis * part.Size.Z / 2)).Position
					end;
				}),
				components.Lifetime({
					duration = params.lifetime or settings.Rocket.lifetime:Get();
					timestamp = crossbow.Params.currentFrame;
				})
		end);
		SuperballTool = toolPack(bind(crossbow, "SuperballTool"));
		Superball = projectilePack(function(params, _, _, velocity, cframe)
			return
				components.Superball({
					maxBounces = params.maxBounces or settings.Superball.maxBounces:Get();
					bouncePauseTime = params.bouncePauseTime or settings.Superball.bouncePauseTime:Get();
					bounces = 0;
					lastHitTimestamp = 0;
				}),
				components.Velocity({
					velocity = cframe.LookVector * velocity;
				}),
				components.Damage({
					filter = params.canDamageFilter or settings.Superball.canDamageFilter:Get();
					amount = params.damageAmount or settings.Superball.damageAmount:Get();
					cooldown = params.damageCooldown or settings.Superball.damageCooldown:Get();
					damage = params.damage or settings.Superball.damage:Get();
					damageType = "Hit";
				}),
				components.Lifetime({
					duration = params.lifetime or settings.Superball.lifetime:Get();
					timestamp = crossbow.Params.currentFrame;
				})
		end);
		Explosion = function(damage, filter)
			return
				components.Damage({
					damage = damage or settings.Explosion.damage:Get();
					filter = filter;
					damageType = "Explosion";
				})
		end;
	}
end
