local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local function updateBodies(world)
	-- If a Part + FixedVelocity was just added/changed, setup physics bodies.
	for id, partRecord in world:queryChanged(Components.Part) do
		if not world:contains(id) then
			continue
		end

		local fixedVelocity = world:get(id, Components.FixedVelocity)
		if not fixedVelocity then
			continue
		end

		if partRecord.new then
			local part = partRecord.new.part
			part.Anchored = false
			
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "BodyVelocity"
			bodyVelocity.Velocity = fixedVelocity.velocity
			bodyVelocity.Parent = part
			
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "BodyGyro"
			bodyGyro.CFrame = CFrame.lookAt(Vector3.zero, fixedVelocity.velocity)
			bodyGyro.Parent = part
		end
	end
	
	-- If a Part + Transform was just added/changed, set the part's CFrame.
	for id, transformRecord in world:queryChanged(Components.Transform) do
		if not world:contains(id) then
			continue
		end

		local part = world:get(id, Components.Part)
		if not part then
			continue
		end

		if transformRecord.new then
			if world:get(id, Components.Superball) then
				part.part.Position = transformRecord.new.cframe.Position
			else
				part.part.CFrame = transformRecord.new.cframe
			end
		end
	end

	for id, velocityRecord in world:queryChanged(Components.Velocity) do
		if not world:contains(id) then
			continue
		end

		local part = world:get(id, Components.Part)
		if not part then
			continue
		end

		if velocityRecord.new then
			part.part.AssemblyLinearVelocity = velocityRecord.new.velocity
		end
	end
	
	-- If a FixedVelocity + Part was just added/changed, update its physics bodies.
	for id, fixedVelocityRecord in world:queryChanged(Components.FixedVelocity) do
		if not world:contains(id) then
			continue
		end

		local part = world:get(id, Components.Part)
		if not part then
			continue
		end

		if fixedVelocityRecord.new then
			part.part.BodyVelocity.Velocity = fixedVelocityRecord.new.velocity
			part.part.BodyGyro.CFrame = CFrame.lookAt(Vector3.zero, fixedVelocityRecord.new.velocity)
		end
	end

	for id, record in world:queryChanged(Components.Antigravity) do
		if not world:contains(id) then
			continue
		end

		local part = world:get(id, Components.Part)
		if not part then
			continue
		end

		if record.new then
			part.part.Anchored = false

			local antigravity = part.part:FindFirstChild("Antigravity")
			if antigravity == nil then
				local attachment = Instance.new("Attachment")
				attachment.Parent = part.part

				antigravity = Instance.new("VectorForce")
				antigravity.Name = "Antigravity"
				antigravity.ApplyAtCenterOfMass = true
				antigravity.RelativeTo = Enum.ActuatorRelativeTo.World
				antigravity.Attachment0 = attachment
			end

			antigravity.Force = Vector3.yAxis * part.part:GetMass() * workspace.Gravity * record.new.factor
			antigravity.Parent = part.part
		end
	end
end

return {
	system = updateBodies;
	event = "PreSimulation";
	priority = Priorities.CoreAfter;
}
