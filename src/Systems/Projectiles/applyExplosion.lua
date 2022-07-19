local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)
local General = require(script.Parent.Parent.Parent.Utilities.General)

local overlapParams = OverlapParams.new()
overlapParams.CollisionGroup = "Crossbow_Projectile"

local function getExplosionImpulseValues(explosionPosition, part, pressure)
	local isInCharacter = not not General.getCharacterFromHitbox(part)

	local delta = part.Position - explosionPosition
	local normal = delta == Vector3.zero and Vector3.yAxis or delta.Unit

	local radius = part.Size.Magnitude / 2
	local surfaceArea = radius * radius
	local impulse = normal * pressure * surfaceArea * (1 / 4560)

	local frac, resolvedMass
	if isInCharacter then
		frac = 2
		resolvedMass = 0
		local parts = part:GetConnectedParts(true)
		for _, p in pairs(parts) do
			resolvedMass += p.Mass
		end
	else
		frac = 1
		resolvedMass = part.Mass
	end

	local deltaVelocity = impulse / resolvedMass

	local rotImpulse = impulse * 0.5 * radius
	-- Moment of inertia = 2/5*m*r^2 (assuming roughly spherical)
	local momentOfInertia = (2 * part:GetMass() * radius * radius / 5)
	local deltaRotVelocity = rotImpulse / momentOfInertia

	local accelNeeded = workspace.Gravity * 10 * frac
	local torqueNeeded = 20 * momentOfInertia * 10 * frac

	return deltaVelocity, accelNeeded, deltaRotVelocity, torqueNeeded
end

local function exertLocally(ExplosionPosition, Part, Pressure)
    local dV, accel, dRV, torque = getExplosionImpulseValues(ExplosionPosition, Part, Pressure)

	local force = accel * Part.Mass

	local bodyV = Instance.new('BodyVelocity', Part)
	bodyV.velocity = Part.Velocity + dV
	bodyV.maxForce = Vector3.new(force, force, force)
	Debris:AddItem(bodyV, 0.1)
	
	--Get rid of bodymover later
	local rot = Instance.new('BodyAngularVelocity', Part)
	rot.angularvelocity = Part.RotVelocity + dRV
	rot.maxTorque = Vector3.new(torque, torque, torque)
	Debris:AddItem(rot, 0.1)
end

local function applyExplosion(world, params)
	for id, part, explodeOnTouch in world:query(Components.Part, Components.ExplodeOnTouch, Components.Owned) do
		local queue = params.hitQueue[id]
		if queue == nil then
			continue
		end

		for _, hit in ipairs(queue) do
			if not params.Settings.Callbacks[explodeOnTouch.filter](hit) then
				continue
			end

			local pos = params.Settings.Callbacks[explodeOnTouch.transform](part.part)
			params.events:fire("explosion", pos, explodeOnTouch.radius, explodeOnTouch.damage, true, id, explodeOnTouch.explodeSound)
			params.events:fire("queueRemove", id)

			break
		end
	end

	for _, pos, radius, damage, isOwned, spawnerId, soundValue in params.events:iterate("explosion") do
		local collision = Instance.new("Part")
		collision.CFrame = CFrame.new(pos)
		collision.Size = Vector3.one * radius * 2

		collision.Transparency = 1
		collision.CanQuery = false
		collision.Anchored = true
		collision.CanCollide = false
		collision.Shape = Enum.PartType.Ball
		collision.Parent = workspace

		if soundValue then
			params.soundPlayer:queueSound(soundValue, nil, pos, 2)
		end

		local newId = params.Crossbow:SpawnBind(collision, params.Packs.Explosion(damage))

		if isOwned then
			world:insert(newId, Components.Owned())
		end

		params.events:fire("exploded", table.freeze({
			spawnerId = spawnerId;
			newId = newId;
			position = pos;
			radius = radius;
			damage = damage;
			isOwned = isOwned;
		}))
	end

	-- .Touched seems to be unreliable with explosions.
	for id, part in world:query(Components.Part, Components.Explosion) do
		params.hitQueue[id] = workspace:GetPartsInPart(part.part, overlapParams)
	end

	local maxMass = params.Settings.ExplosionsEatParts.maxMass:Get()
	local ateQueue = {}

    for id in world:query(Components.Part, Components.Explosion) do
        local queue = params.hitQueue[id]
        if queue == nil then
            continue
        end

        for _, hit in ipairs(queue) do
            if
                not hit.Anchored
                and not CollectionService:HasTag(hit, "BB_NonExplodable")
                and not CollectionService:HasTag(hit, "Crossbow_Projectile")
                and hit:GetMass() <= maxMass
                and not General.getCharacter(hit)
            then
                ateQueue[hit] = true
                hit.Parent = nil
            end
        end
    end

    for id, part in world:query(Components.Part, Components.Explosion) do
        local queue = params.hitQueue[id]
        if queue == nil then
            continue
        end

        for _, hit in ipairs(queue) do
            if not ateQueue[hit] then
                exertLocally(part.part.Position, hit, 500_000)
            end
        end
    end
end

return {
	system = applyExplosion;
	event = "PostSimulation";
	priority = Priorities.Projectiles;
}