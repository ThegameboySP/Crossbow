local Players = game:GetService("Players")

local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local useHookStorage = require(script.Parent.Parent.Parent.Shared.useHookStorage)
local Priorities = require(script.Parent.Parent.Priorities)
local Components = require(script.Parent.Parent.Parent.Components)

local NULL = string.char(0)

local function resolveDiff(whitelist, new, old)
	debug.profilebegin("replication: diff")
	local diff = {}

	if whitelist then
		for k in pairs(whitelist) do
			local newValue = new[k]

			if old[k] ~= newValue then
				if newValue == nil then
					diff[k] = NULL
				else
					diff[k] = new[k]
				end
			end
		end
	else
		for k, v in pairs(new) do
			if old[k] ~= v then
				diff[k] = v
			end
		end

		for k in pairs(old) do
			if new[k] == nil then
				diff[k] = NULL
			end
		end
	end

	debug.profileend()

	return diff
end

local returnTableMt = {__index = function(t, k)
	local tbl = {}
	t[k] = tbl
	return tbl
end}
local newPlayers = {}
local EMPTY_TBL = table.freeze({})

local function serverReplication(world, params)
	local newComponents = {}
	local removedComponents = {}

	for _, player in Matter.useEvent(Players, params.playerAdded or "PlayerAdded") do
		newPlayers[player] = true
	end

	debug.profilebegin("replication: get changed")

	-- :queryChanged only brings you the latest old value.
	-- This isn't what we want, so we need to store old component values ourselves.
	local oldValues = setmetatable(useHookStorage(), returnTableMt)

	for _, definition in pairs(Components) do
		if definition.noReplicate then continue end
		
		for id, record in world:queryChanged(definition) do
			if not world:contains(id) then
				oldValues[definition][id] = nil
				continue
			end

			id = tostring(id)

			if record.new then
				local diff = resolveDiff(definition.replicateKeys, record.new, oldValues[definition][id] or EMPTY_TBL)
				if next(diff) == nil then
					continue
				end

				newComponents[id] = newComponents[id] or {}
				newComponents[id][definition.componentName] = diff
				oldValues[definition][id] = record.new
			else
				oldValues[definition][id] = nil
				table.insert(removedComponents, {id, definition.componentName})
			end
		end
	end

	debug.profileend()

	if next(newComponents) or removedComponents[1] then
		for _, player in pairs(params.getPlayers and params.getPlayers() or Players:GetPlayers()) do
			if not newPlayers[player] then
				params.remoteEvents:fire("out", "replication", player, newComponents, removedComponents)
			end
		end
	end

	if next(newPlayers) then
		local new = {}

		for _, definition in pairs(Components) do
			if definition.noReplicate then continue end

			for id, component in world:query(definition) do
				id = tostring(id)
				new[id] = new[id] or {}
				new[id][definition.componentName] = resolveDiff(definition.replicateKeys, component, EMPTY_TBL)
			end
		end

		for player in pairs(newPlayers) do
			params.remoteEvents:fire("out", "replication", player, new, EMPTY_TBL)
			newPlayers[player] = nil
		end
	end
end

return {
	realm = "server";
	system = serverReplication;
	event = "PostSimulation";
	priority = Priorities.RemoteAfter;
}