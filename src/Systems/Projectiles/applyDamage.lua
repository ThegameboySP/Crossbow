local General = require(script.Parent.Parent.Parent.Utilities.General)
local Priorities = require(script.Parent.Parent.Priorities)

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local applyExplosion = require(script.Parent.applyExplosion)
local EventQueue = require(script.Parent.Parent.Parent.Utilities.EventQueue)

local function initState(state)
	state.touched = EventQueue.new()
end

local function applyDamage(world, components, params)
	local settings = params.Settings
	local dealDamage = settings.Interfacing.dealDamage:Get()
	local getTouchedSignal = settings.Interfacing.getTouchedSignal:Get()
	local currentTime = params.currentFrame
	local damaged = {}

	local touched = useHookStorage(nil, initState).touched

	for id in world:queryChanged(components.Part) do
		touched:disconnect(id)
	end

	for id, record in world:queryChanged(components.Damage) do
		if not record.new then
			touched:disconnect(id)
		end
	end

	for id, part, damage in world:query(components.Part, components.Damage, components.Owned) do
		if damage.amount <= 0 then
			world:remove(id, components.Damage)
			touched:disconnect(id)
			continue
		end

		if currentTime - damage.damagedTimestamp < damage.cooldown then
			continue
		end

		if not touched:isConnected(id) then
			touched:connect(id, getTouchedSignal(part.part))
		end

		for _, hit in touched:iterate(id) do
			local victim, humanoid = General.getCharacterFromHitbox(hit)
			if victim == nil then continue end
			if humanoid.Health <= 0 then continue end
			if damaged[part] and damaged[part][victim] then continue end

			local projectile = world:get(id, components.Projectile)
			if not settings.Callbacks[damage.filter](victim, projectile and projectile.character, damage.damageType) then continue end

			if params.Crossbow.IsServer then
				dealDamage(humanoid, damage.damage, damage.damageType, true)
			end

			params.events:fire("damaged", table.freeze({
				humanoid = humanoid;
				damageComponent = damage;
				sourceId = id;
			}))

			if not world:get(id, components.SwordTool) then
				params.events:fire("playSound", params.Settings.Sounds.successfulHit:Get())
			end

			damaged[part] = damaged[part] or {}
			damaged[part][victim] = true

			world:insert(id, damage:patch({
				amount = damage.amount - 1;
				damagedTimestamp = currentTime;
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