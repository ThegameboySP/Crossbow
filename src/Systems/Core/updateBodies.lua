local Priorities = require(script.Parent.Parent.Priorities)

local function updateBodies(world, components)
	-- If a Part + Transform was just added/changed, set its CFrame and setup physics bodies.
	for id, partRecord, transform in world:queryChanged(components.Part, components.Transform) do
		if partRecord.new then
			local part = partRecord.new.part
			part.Anchored = false
			part.Massless = true
			
			local velocity = world:get(id, components.Velocity)
			if velocity then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Name = "BodyVelocity"
				bodyVelocity.Velocity = velocity.velocity
				bodyVelocity.Parent = part
			else
				local bodyPosition = Instance.new("BodyPosition")
				bodyPosition.Name = "BodyPosition"
				bodyPosition.Parent = part
			end
			
			local bodyGyro = Instance.new("BodyGyro")
			bodyGyro.Name = "BodyGyro"
			bodyGyro.Parent = part
			
			if not transform.doNotReconcile then
				part.CFrame = transform.cframe
				if velocity == nil then
					part.BodyPosition.Position = transform.cframe.Position
				end
				bodyGyro.CFrame = transform.cframe
			end
		end
	end
	
	-- Handle Transform added/changed to existing entity with Part
	for id, transformRecord, part in world:queryChanged(components.Transform, components.Part) do
		if transformRecord.new and not transformRecord.new.doNotReconcile then
			local velocity = world:get(id, components.Velocity)
			if velocity == nil then
				part.part.BodyPosition.Position = transformRecord.new.cframe.Position
			end
			
			part.part.BodyGyro.CFrame = transformRecord.new.cframe
		end
	end
	
	for _id, velocityRecord, part in world:queryChanged(components.Velocity, components.Part) do
		if velocityRecord.new then
			part.part.BodyVelocity.Velocity = velocityRecord.new.velocity
		end
	end
end

return {
	system = updateBodies;
	event = "PreSimulation";
	priority = Priorities.CoreAfter;
}
