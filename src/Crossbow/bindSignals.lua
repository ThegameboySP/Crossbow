local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Parent.Utilities.Signal)

local legacyNameMap = {
	RenderStepped = "PreRender";
	Stepped = "PreSimulation";
	Heartbeat = "PostSimulation";
}

return function(middleware)
	local signals = {
		RenderStepped = Signal.new();
		Stepped = Signal.new();
		Heartbeat = Signal.new();
	}

	for signalName, signal in pairs(signals) do
		if signalName == "RenderStepped" and RunService:IsServer() then
			continue
		end
		
		RunService[signalName]:Connect(middleware(function()
			signal:Fire()
		end, legacyNameMap[signalName]))
	end

	return {
		PreRender = signals.RenderStepped;
		PreSimulation = signals.Stepped;
		PostSimulation = signals.Heartbeat;
	}
end