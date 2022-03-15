local Priorities = require(script.Parent.Parent.Priorities)

local function fireRemotes(_, _, params)
	if not params.remoteEvents:isEmpty() then
		if params.Crossbow.IsServer then
			local clientEvents = {}

			for _, event in ipairs(params.remoteEvents:get("out")) do
				local events = clientEvents[event[2]]
				if events == nil then
					events = {}
					clientEvents[event[2]] = events
				end

				table.insert(events, {event[1], unpack(event, 3)})
			end

			for client, events in pairs(clientEvents) do
				params.remoteEvent:FireClient(client, events)
			end
		else
			params.remoteEvent:FireServer(params.remoteEvents:get("out"))
		end
	end
end

return {
	system = fireRemotes;
	event = "PostSimulation";
	priority = Priorities.RemoteAfter + 1;
}