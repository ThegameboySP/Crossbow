local Players = game:GetService("Players")

local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local newPlayers = {}

local function serverReplication(world, components, params)
	local newComponents = {}
	local removedComponents = {}

	for _, player in Matter.useEvent(Players, params.playerAdded or "PlayerAdded") do
		newPlayers[player] = true
	end

	for _, definition in pairs(components) do
		if definition.noReplicate then continue end
		
		for id, changedRecord in world:queryChanged(definition) do
			if changedRecord.new then
				newComponents[id] = newComponents[id] or {}
				newComponents[id][tostring(definition)] = changedRecord.new
			else
				table.insert(removedComponents, {id, tostring(definition)})
			end
		end
	end
	
	if next(newComponents) or removedComponents[1] then
		for _, player in pairs(params.getPlayers and params.getPlayers() or Players:GetPlayers()) do
			if not newPlayers[player] then
				params.events:fire("remote", "replication", player, newComponents, removedComponents)
			end
		end
	end

	for player in pairs(newPlayers) do
		local new = {}

		for _, definition in pairs(components) do
			if definition.noReplicate then continue end

			for id, component in world:query(definition) do
				new[id] = new[id] or {}
				new[id][tostring(definition)] = component
			end
		end

		params.events:fire("remote", "replication", player, new, {})

		newPlayers[player] = nil
	end
end

return {
	realm = "server";
	system = serverReplication;
	event = "PostSimulation";
	priority = Priorities.RemoteAfter;
}