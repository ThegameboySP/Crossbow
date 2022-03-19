local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)

local applyExplosion = require(script.Parent.applyExplosion)

local function applyDamage(world, components, params)
	local getTouchedSignal = params.Settings.Interfacing.getTouchedSignal:Get()
	local dealDamage = params.Settings.Interfacing.dealDamage:Get()
	local currentTime = params.currentFrame
	local damaged = {}

	for id, part, damage in world:query(components.Part, components.Damage, components.Local) do
		if damage.damagedTimestamp - currentTime < damage.cooldown then
			continue
		end

		for _, hit in Matter.useEvent(part.part, getTouchedSignal(part.part)) do
			local character = General.getCharacterFromHitbox(hit)
			if character == nil then continue end
			if damaged[part] and damaged[part][character] then continue end

			local projectile = world:get(id, components.Projectile)
			if not damage.filter(character, projectile and projectile.character, damage.damageType) then continue end

			if params.Crossbow.IsServer then
				dealDamage(character.Humanoid, damage.damage, damage.damageType, true)
			end

			params.events:fire("damaged", table.freeze({
				humanoid = character.Humanoid;
				damageComponent = damage;
				sourceId = id;
			}))

			damaged[part] = damaged[part] or {}
			damaged[part][character] = true

			world:insert(id, damage:patch({
				amount = damage.amount - 1;
				damagedTimestamp = currentTime;
			}))
		end
	end

	for id, damageRecord in world:queryChanged(components.Damage) do
		if not damageRecord.new then continue end

		if damageRecord.new.amount <= 0 then
			world:remove(id, components.Damage)
		end
	end
end

return {
	system = applyDamage;
	event = "PreSimulation";
	after = { applyExplosion };
	priority = Priorities.Projectiles + 9;
}