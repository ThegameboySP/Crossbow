local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)

local applyExplosion = require(script.Parent.applyExplosion)

local function applyDamage(world, components, params)
	local settings = params.Settings
	local dealDamage = settings.Interfacing.dealDamage:Get()
	local currentTime = params.currentFrame
	local damaged = {}

	for id, part, damage in world:query(components.Part, components.Damage, components.Owned) do
		if damage.amount <= 0 then
			world:remove(id, components.Damage)
			continue
		end

		if currentTime - damage.timestamp < damage.cooldown then
			continue
		end

		local queue = params.hitQueue[id]
		if not queue then
			continue
		end

		for _, hit in ipairs(queue) do
			local victim, humanoid = General.getCharacterFromHitbox(hit)
			if victim == nil then continue end
			if humanoid.Health <= 0 then continue end
			if damaged[part] and damaged[part][victim] then continue end

			local projectile = world:get(id, components.Projectile)
			local damageFilter = settings.Callbacks[damage.filter]
			if not damageFilter(victim, projectile and projectile.character, damage.damageType) then
				continue
			end

			local damageAmount = damage.damage
			
			if params.Crossbow.IsServer then
				dealDamage(humanoid, damageAmount, damage.damageType, true)
			end

			params.events:fire("damaged", table.freeze({
				humanoid = humanoid;
				damage = damageAmount;
				damageType = damage.damageType;
				sourceId = id;
			}))

			if not world:get(id, components.SwordTool) then
				params.events:fire("playSound", params.Settings.Sounds.successfulHit:Get())
			end

			damaged[part] = damaged[part] or {}
			damaged[part][victim] = true

			world:insert(id, damage:patch({
				amount = damage.amount - 1;
				timestamp = currentTime;
			}))

			if (damage.amount - 1) == 0 then
				break
			end
		end
	end
end

return {
	system = applyDamage;
	event = "PreSimulation";
	after = { applyExplosion };
	priority = Priorities.Projectiles + 9;
}