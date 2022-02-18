local Priorities = require(script.Parent.Parent.Priorities)

local function fireRemotes(_, _, params)
	if params.events.remote then
		if params.Crossbow.IsServer then
			local packedClientBodies = {}

			for index, body in ipairs(params.events.remote) do
				local clientBodies = packedClientBodies[body[2]]
				if clientBodies == nil then
					clientBodies = {}
					packedClientBodies[body[2]] = clientBodies
				end

				clientBodies[index] = {body[1], unpack(body, 3)}
			end

			for client, bodies in pairs(packedClientBodies) do
				params.remoteEvent:FireClient(client, bodies)
			end
		else
			params.remoteEvent:FireServer(params.events.remote)
		end
	end
end

return {
	system = fireRemotes;
	event = "PostSimulation";
	priority = Priorities.RemoteAfter + 1;
}