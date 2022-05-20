local Priorities = require(script.Parent.Parent.Priorities)

local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)

local function queueRemoveLifetime(world, components, params)
	local query = useHookStorage()

	for id, lifetimeRecord in world:queryChanged(components.Lifetime) do
		if lifetimeRecord.new then
			query[id] = lifetimeRecord.new
		else
			query[id] = nil
		end
	end
	
	local currentFrame = params.currentFrame
	for id, lifetime in pairs(query) do
		if (currentFrame - lifetime.timestamp) >= lifetime.duration then
            params.events:fire("queueRemove", id)
		end
	end
end

return {
	system = queueRemoveLifetime;
	event = "PreSimulation";
	priority = Priorities.CoreBefore;
}