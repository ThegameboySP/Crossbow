local Matter = require(script.Parent.Parent.Parent.Parent.Matter)
local Priorities = require(script.Parent.Parent.Priorities)

local function getRemotes(_, _, params)
	if params.Crossbow.IsServer then
		for _, client, bodies in Matter.useEvent(params.remoteEvent, "OnServerEvent") do
			-- TODO: is this necessary?
			if client == nil or not client:IsDescendantOf(game) then
				continue
			end

			for _, body in pairs(bodies) do
				params.events:fire("remote-" .. body[1], client, unpack(body, 2))
			end
		end
	else
		for _, bodies in Matter.useEvent(params.remoteEvent, "OnClientEvent") do
			for _, body in ipairs(bodies) do
				params.events:fire("remote-" .. body[1], unpack(body, 2))
			end
		end
	end
end

return {
	system = getRemotes;
	event = "PreSimulation";
	priority = Priorities.RemoteBefore;
}