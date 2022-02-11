local Matter = require(script.Parent.Parent.Parent.Parent.Matter)

local function getRemotes(_, params)
	if params.Crossbow.IsServer then
		for client, bodies in Matter.useEvent(params.remoteEvent, "OnServerEvent") do
			for name, body in pairs(bodies) do
				params.events:fire("remote-" .. name, client, unpack(body))
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
	priority = -101;
}