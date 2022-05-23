local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local updateRicochets = require(script.Parent.updateRicochets)

local function applyDamage(world, params)
	local settings = params.Settings
	local dealDamage = settings.Interfacing.dealDamage:Get()
	local currentTime = params.currentFrame
	local damaged = {}

	for id, part, damage in world:query(Components.Part, Components.Damage, Components.Owned) do
		if damage.amount <= 0 then
			world:remove(id, Components.Damage)
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

			local projectile = world:get(id, Components.Projectile)
			local damageFilter = settings.Callbacks[damage.filter]
			if not damageFilter(victim, projectile and projectile.character, damage.damageType) then
				continue
			end

			local ricochets = world:get(id, Components.Ricochets)
			local damageAmount = damage.damage
			if ricochets then
				damageAmount *= ricochets.damageMultiplier^ricochets.ricochets
			end
			
			if params.Crossbow.IsServer then
				dealDamage(humanoid, damageAmount, damage.damageType, true)
			end

			params.events:fire("damaged", table.freeze({
				humanoid = humanoid;
				damage = damageAmount;
				damageType = damage.damageType;
				sourceId = id;
			}))

			if not world:get(id, Components.SwordTool) then
				params.soundPlayer:queueSound(params.Settings.Sounds.successfulHit:Get())
			end

			damaged[part] = damaged[part] or {}
			damaged[part][victim] = true

			world:insert(id, damage:patch({
				amount = damage.amount - 1;
				timestamp = currentTime;
			}))

			if (damage.amount - 1) == 0 then
				if damage.removeOnNoDamage then
					params.events:fire("queueRemove", id)
				end

				break
			end
		end
	end
end

return {
	system = applyDamage;
	event = "PostSimulation";
	after = { updateRicochets };
	priority = Priorities.Projectiles + 9;
}