local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local function getRemotes(_, params)
	if params.Crossbow.IsServer then
		for _, client, events in Matter.useEvent(params.remoteEvent, "OnServerEvent") do
			-- TODO: is this necessary?
			if client == nil or not client:IsDescendantOf(game) then
				continue
			end

			for _, event in ipairs(events) do
				params.remoteEvents:fire("in-" .. event[1], client, unpack(event, 2))
			end
		end
	else
		for _, events in Matter.useEvent(params.remoteEvent, "OnClientEvent") do
			for _, event in ipairs(events) do
				params.remoteEvents:fire("in-" .. event[1], unpack(event, 2))
			end
		end
	end
end

return {
	system = getRemotes;
	event = "PreSimulation";
	priority = Priorities.RemoteBefore;
}