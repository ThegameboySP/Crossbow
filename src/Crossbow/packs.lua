local function generateToolPack(crossbow)
	return function(generate)
		return function(character, params)
			local components = crossbow.Components
			local userComponents = {generate(crossbow, params or {})}

			return
				components.Exists(),
				components.Tool({
					character = character;
					component = getmetatable(userComponents[1]);
				}),
				components.Local(),
				unpack(userComponents)
		end
	end
end

local function generateProjectilePack(crossbow)
	return function(generate)
		return function(spawnerId, tool, specificTool, spawnPos, params)
			local components = crossbow.Components
			local userComponents = {generate(crossbow, params or {})}

			local cframe = specificTool.getProjectileCFrame(tool, specificTool.spawnDistance, spawnPos)
			return
				components.Exists(),
				components.Projectile({
					spawnerId = spawnerId;
					component = getmetatable(userComponents[1]);
				}),
				components.Transform({
					cframe = cframe
				}),
				components.Velocity({
					velocity = cframe.LookVector * specificTool.velocity;
				}),
				components.Local(),
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
		Rocket = projectilePack(function(params)
			return
				components.Rocket(),
				components.ExplodeOnTouch({
					damage = params.explosionDamage or settings.Rocket.explosionDamage:Get();
					radius = params.radius or settings.Rocket.explosionRadius:Get();
					filter = params.explodeFilter or settings.Rocket.explodeFilter:Get();
				}),
				components.Lifetime({
					duration = params.lifetime or settings.Rocket.lifetime:Get();
					timestamp = os.clock()--(params.binding or crossbow.Binding):GetTime();
				})
		end);
	}
end
