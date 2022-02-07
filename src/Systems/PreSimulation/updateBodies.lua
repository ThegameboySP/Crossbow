local Components = require(script.Parent.Parent.Parent.Components)

local updateToolActions = require(script.Parent.updateToolActions)

local function updateBodies(world)
	-- If a Part + Transform was just added/changed, set its CFrame and setup physics bodies.
	for id, partRecord, transform in world:queryChanged(Components.Part, Components.Transform) do
		if partRecord.new then
			local part = partRecord.new.part
			part.Anchored = false
			part.Massless = true
			
			local velocity = world:get(id, Components.Velocity)
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
	for id, transformRecord, part in world:queryChanged(Components.Transform, Components.Part) do
		if transformRecord.new and not transformRecord.new.doNotReconcile then
			local velocity = world:get(id, Components.Velocity)
			if velocity == nil then
				part.part.BodyPosition.Position = transformRecord.new.cframe.Position
			end
			
			part.part.BodyGyro.CFrame = transformRecord.new.cframe
		end
	end
	
	for _id, velocityRecord, part in world:queryChanged(Components.Velocity, Components.Part) do
		if velocityRecord.new then
			part.part.BodyVelocity.Velocity = velocityRecord.new.velocity
		end
	end
end

return {
	system = updateBodies;
	after = { updateToolActions };
	event = "PreSimulation";
}
