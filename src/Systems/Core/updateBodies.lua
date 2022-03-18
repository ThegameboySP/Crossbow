local Priorities = require(script.Parent.Parent.Priorities)

local function updateBodies(world, components)
	-- If a Part + FixedVelocity was just added/changed, setup physics bodies.
	for _id, partRecord, fixedVelocity in world:queryChanged(components.Part, components.FixedVelocity) do
		if partRecord.new then
			local part = partRecord.new.part
			part.Anchored = false
			part.Massless = true
			
			local bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.Name = "BodyVelocity"
			bodyVelocity.Velocity = fixedVelocity.velocity
			bodyVelocity.Parent = part
			
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "BodyGyro"
			bodyGyro.Parent = part
			
			bodyVelocity.Velocity = fixedVelocity.velocity
			bodyGyro.CFrame = CFrame.lookAt(Vector3.zero, fixedVelocity.velocity)
		end
	end
	
	for _id, velocityRecord, part in world:queryChanged(components.Velocity, components.Part) do
		if velocityRecord.new then
			part.part.AssemblyLinearVelocity = velocityRecord.new.velocity
		end
	end

	-- If a Part + Transform was just added/changed, set the part's CFrame.
	for _id, transformRecord, part in world:queryChanged(components.Transform, components.Part) do
		if transformRecord.new then
			part.part.CFrame = transformRecord.new.cframe
		end
	end
	
	-- If a FixedVelocity + Part was just added/changed, update its physics bodies.
	for _id, fixedVelocityRecord, part in world:queryChanged(components.FixedVelocity, components.Part) do
		if fixedVelocityRecord.new then
			part.part.BodyVelocity.Velocity = fixedVelocityRecord.new.velocity
			part.part.BodyGyro.CFrame = CFrame.lookAt(Vector3.zero, fixedVelocityRecord.new.velocity)
		end
	end
end

return {
	system = updateBodies;
	event = "PreSimulation";
	priority = Priorities.CoreAfter;
}
